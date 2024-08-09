/*
    File Name: SQL_Server_Jobs_Info.sql
    Author: Miriam Figueroa
    Created Date: August 10, 2024
    
    Description:
    This script retrieves detailed information about SQL Server Agent jobs configured on the instance.
    It provides details on the job name, status, schedule, last run time, last run outcome, and more.

    Expected Output:
    The script returns a result set with the following details for each job:
    - Job Name
    - Job Enabled
    - Job Description
    - Schedule Name
    - Schedule Enabled
    - Last Run Date and Time
    - Last Run Outcome
    - Next Run Date and Time

    Usage:
    Run this script to audit and review SQL Server Agent jobs configured on your SQL Server instance. 
    Use the output to ensure that jobs are running as expected and investigate any failures or misconfigurations.
*/

SELECT 
    J.name AS JobName,
    J.enabled AS JobEnabled,
    J.description AS JobDescription,
    S.name AS ScheduleName,
    S.enabled AS ScheduleEnabled,
    msdb.dbo.agent_datetime(H.run_date, H.run_time) AS LastRunDateTime,
    CASE H.run_status
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
    END AS LastRunOutcome,
    msdb.dbo.agent_datetime(JS.next_run_date, JS.next_run_time) AS NextRunDateTime
FROM 
    msdb.dbo.sysjobs AS J
LEFT JOIN 
    msdb.dbo.sysjobschedules AS JS ON J.job_id = JS.job_id
LEFT JOIN 
    msdb.dbo.sysschedules AS S ON JS.schedule_id = S.schedule_id
LEFT JOIN 
    msdb.dbo.sysjobhistory AS H ON J.job_id = H.job_id 
        AND H.instance_id = (SELECT MAX(H2.instance_id) 
                             FROM msdb.dbo.sysjobhistory H2 
                             WHERE H2.job_id = J.job_id)
ORDER BY 
    J.name;
