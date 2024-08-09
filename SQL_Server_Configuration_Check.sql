/*
    File Name: SQL_Server_Configuration_Check.sql
    Author: Miriam Figueroa
    Created Date: August 09, 2024
    
    Description:
    This script gathers key SQL Server configuration settings for each instance. 
    It helps administrators audit and review SQL Server settings to ensure consistency across the environment.

    Expected Output:
    The script returns a single result set with key configuration details, including memory settings, CPU settings,
    parallelism, worker threads, and physical/logical CPU cores.

    Usage:
    Run this script periodically (e.g., monthly) as part of your SQL Server maintenance routine.
    Analyze the output to ensure SQL Server instances are configured according to your organization's best practices.
    Store the output or script in a version-controlled repository (e.g., GitHub) to track configuration changes over time.
*/

-- Step 1: Enable advanced options
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- Step 2: Retrieve SQL Server Configuration Settings
SELECT 
    SERVERPROPERTY('MachineName') AS ServerName,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('EngineEdition') AS EngineEdition,
    SERVERPROPERTY('IsClustered') AS IsClustered,
    SERVERPROPERTY('IsHadrEnabled') AS IsHadrEnabled,
    SERVERPROPERTY('Collation') AS Collation,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'max server memory (MB)') AS MaxServerMemory_MB,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'min server memory (MB)') AS MinServerMemory_MB,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'cost threshold for parallelism') AS CostThresholdForParallelism,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'max degree of parallelism') AS MaxDegreeOfParallelism,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'optimize for ad hoc workloads') AS OptimizeForAdHocWorkloads,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'recovery interval (min)') AS RecoveryIntervalMin,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'min worker threads') AS MinWorkerThreads,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'max worker threads') AS MaxWorkerThreads,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'default full-text language') AS DefaultFullTextLanguage,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'default language') AS DefaultLanguage,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'priority boost') AS PriorityBoost,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'lightweight pooling') AS LightweightPooling,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'remote admin connections') AS RemoteAdminConnections,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'clr enabled') AS ClrEnabled,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'backup compression default') AS BackupCompressionDefault,
    cpu_count AS LogicalProcessors,
    hyperthread_ratio AS HyperthreadRatio,
    scheduler_count AS SchedulerCount,  -- Number of CPU schedulers, which usually corresponds to the number of CPU cores
    cpu_count / hyperthread_ratio AS PhysicalCPUCount,  -- Estimated number of physical CPU cores
    physical_memory_kb / 1024 AS PhysicalMemory_MB,
    committed_kb / 1024 AS CommittedMemory_MB,
    committed_target_kb / 1024 AS TargetCommittedMemory_MB
FROM 
    sys.dm_os_sys_info;

-- Step 3: Disable advanced options (optional)
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
