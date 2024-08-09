/*
    File Name: SQL_Server_Alerts_Check.sql
    Author: Miriam Figueroa
    Created Date: August 09, 2024
    
    Description:
    This script retrieves information about SQL Server alerts configured on the instance.
    It provides details on whether the alerts are enabled, their descriptions, the last time they were triggered,
    and the total number of times they have been triggered.

    Expected Output:
    The script returns a result set with the following details for each alert:
    - Alert Name
    - Is Enabled
    - Alert Message ID
    - Severity
    - Alert Description
    - Last Occurrence Date
    - Total Occurrences

    Usage:
    Run this script to audit and review the alerts configured on your SQL Server instance. 
    Use the output to ensure that critical alerts are enabled and functioning as expected.
*/

SELECT 
    A.name AS AlertName,
    A.enabled AS IsEnabled,
    A.message_id AS MessageID,
    A.severity AS Severity,
    ISNULL(A.event_source, '') AS EventSource,
    ISNULL(A.database_name, '') AS DatabaseName,
    ISNULL(A.event_description_keyword, '') AS AlertDescription,
    ISNULL(MAX(H.run_date), '') AS LastOccurrenceDate,
    COUNT(H.instance_id) AS TotalOccurrences
FROM 
    msdb.dbo.sysalerts AS A
LEFT JOIN
    msdb.dbo.sysjobs AS J ON A.job_id = J.job_id
LEFT JOIN
    msdb.dbo.sysjobhistory AS H ON J.job_id = H.job_id
GROUP BY 
    A.name,
    A.enabled,
    A.message_id,
    A.severity,
    A.event_source,
    A.database_name,
    A.event_description_keyword
ORDER BY 
    A.name;
