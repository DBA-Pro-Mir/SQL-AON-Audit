/*
Script for Analyzing SQL Server Memory Usage and Plan Cache

This script includes a set of queries to analyze how SQL Server is utilizing memory, 
including memory usage by different components, buffer pool usage, query memory grants, 
plan cache utilization, and Resource Governor configuration. 

These queries can help diagnose why SQL Server may not be using all the allocated memory 
and provide insights into how memory is being consumed.

Author: Miriam Figueroa
Date: 08-22-2024
*/

-- Step 1: Identify Memory Distribution across Memory Clerks
/*
This query helps identify how memory is distributed across different memory clerks 
within SQL Server. It shows how much memory each type of clerk is using.
*/
SELECT 
    type AS MemoryClerkType,
    SUM(pages_kb) / 1024 AS MemoryUsageMB
FROM 
    sys.dm_os_memory_clerks
GROUP BY 
    type
ORDER BY 
    MemoryUsageMB DESC;
GO


-- Step 2: Analyze Buffer Pool Usage
/*
This query provides a breakdown of buffer pool usage by each database. 
The buffer pool is the largest consumer of memory, used to cache data pages and index pages.
*/
SELECT 
    COUNT(*) * 8 / 1024 AS BufferPoolUsageMB, 
    CASE database_id
        WHEN 32767 THEN 'ResourceDB'
        ELSE DB_NAME(database_id)
    END AS DatabaseName
FROM 
    sys.dm_os_buffer_descriptors
GROUP BY 
    database_id
ORDER BY 
    BufferPoolUsageMB DESC;
GO


-- Step 3: Check Query Memory Grants
/*
This query shows the memory granted to queries. It helps identify if SQL Server is granting 
sufficient memory to queries and if the granted memory aligns with the total available memory.
*/
SELECT 
    session_id, 
    requested_memory_kb / 1024 AS RequestedMemoryMB,
    granted_memory_kb / 1024 AS GrantedMemoryMB,
    query_cost, 
    plan_handle
FROM 
    sys.dm_exec_query_memory_grants
WHERE 
    granted_memory_kb > 0;
GO


-- Step 4: Monitor Plan Cache Usage
/*
This query analyzes the size and usage of the plan cache. It shows the different types of cached plans, 
the number of plans, and the memory used by each type. This helps identify if the plan cache is using 
a significant amount of memory and if there are opportunities for optimization.
*/
SELECT 
    cp.objtype AS ObjectType,
    COUNT(*) AS NumberOfPlans,
    SUM(cp.size_in_bytes) / 1024 / 1024 AS CacheSizeMB,
    SUM(CAST(qs.total_worker_time AS BIGINT)) / 1000.0 / 60.0 AS TotalWorkerTimeMinutes,
    SUM(CAST(qs.total_elapsed_time AS BIGINT)) / 1000.0 / 60.0 AS TotalElapsedTimeMinutes
FROM 
    sys.dm_exec_cached_plans AS cp
JOIN 
    sys.dm_exec_query_stats AS qs ON cp.plan_handle = qs.plan_handle
GROUP BY 
    cp.objtype
ORDER BY 
    CacheSizeMB DESC;
GO


-- Step 5: Analyze Resource Governor Configuration
/*
This query provides an overview of the Resource Governor's resource pools, including memory usage, 
CPU usage, and the configuration of minimum and maximum memory and CPU percentages.
*/
SELECT 
    pool_id,
    name,
    statistics_start_time,
    total_cpu_usage_ms,
    cache_memory_kb,
    compile_memory_kb,
    used_memgrant_kb,
    total_memgrant_count,
    total_memgrant_timeout_count,
    active_memgrant_count,
    active_memgrant_kb,
    memgrant_waiter_count,
    max_memory_kb,
    used_memory_kb,
    target_memory_kb,
    out_of_memory_count,
    min_cpu_percent,
    max_cpu_percent,
    min_memory_percent,
    max_memory_percent,
    cap_cpu_percent,
    total_cpu_active_ms
FROM 
    sys.dm_resource_governor_resource_pools
ORDER BY 
    pool_id;
GO


-- Step 6: Check Page Life Expectancy (PLE)
/*
Page Life Expectancy (PLE) measures the average time (in seconds) a page of data stays in memory.
A low PLE may indicate memory pressure. This query retrieves the current PLE value.
*/
SELECT 
    [object_name], 
    [counter_name], 
    [cntr_value] AS PageLifeExpectancy
FROM 
    sys.dm_os_performance_counters 
WHERE 
    [counter_name] = 'Page life expectancy';
GO
