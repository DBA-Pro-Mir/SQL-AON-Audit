/*
    File Name: AON_Monthly_Configuration_Audit.sql
    Author: Miriam Figueroa
    Created Date: 08/09/2024
    
    Description:
    This script is used to audit and verify the configuration of Always On Availability Groups (AON)
    and Windows Failover Clustering (WFCS) environments. The script gathers key configuration details 
    from SQL Server instances participating in AON, including memory allocation, CPU settings, node roles, 
    failover modes, and cluster quorum settings. It is intended to be executed monthly to ensure 
    consistency and optimal configuration across all nodes in the environment.

    Expected Results:
    The script returns a result set with the following information:
    - ServerName: Name of the SQL Server instance.
    - IsClustered: Indicates whether the instance is part of a cluster.
    - SQLVersion: Version of SQL Server installed.
    - SQLProductLevel: The service pack level of the SQL Server.
    - SQLEdition: The edition of SQL Server (e.g., Standard, Enterprise).
    - IsHadrEnabled: Indicates if Always On is enabled on the server.
    - SQLProcessID: Process ID of the SQL Server instance.
    - NumberOfProcessors: Number of processors assigned to the SQL Server instance.
    - MaxServerMemory_MB: Maximum memory allocated to SQL Server in MB.
    - TotalCPUCount: Total number of CPUs available on the server.
    - HyperthreadRatio: Ratio of hyperthreaded to physical CPUs.
    - ClusterName: Name of the Windows Failover Cluster.
    - QuorumType: Type of quorum configuration.
    - QuorumState: Current state of the quorum.
    - AvailabilityGroupName: Name of the Always On Availability Group.
    - ReplicaServerName: Name of the server replica in the Availability Group.
    - NodeRole: Role of the node (Primary/Secondary).
    - AvailabilityMode: Availability mode (Synchronous/Asynchronous).
    - FailoverMode: Failover mode (Automatic/Manual).
    - SessionTimeout: Timeout value for the session.
    - PrimaryRoleConnections: Connection policy for the primary role.
    - SecondaryRoleConnections: Connection policy for the secondary role.
    - BackupPriority: Priority setting for backups on this replica.
    - ReadOnlyRoutingURL: URL for routing read-only connections.
*/





-- CTE to gather Availability Group and Replica configurations
WITH AG_Config AS (
    SELECT 
        AG.name AS AvailabilityGroupName,
        AR.replica_server_name AS ReplicaServerName,
        AR.availability_mode_desc AS AvailabilityMode,
        AR.failover_mode_desc AS FailoverMode,
        AR.session_timeout AS SessionTimeout,
        AR.primary_role_allow_connections_desc AS PrimaryRoleConnections,
        AR.secondary_role_allow_connections_desc AS SecondaryRoleConnections,
        AR.backup_priority AS BackupPriority,
        AR.read_only_routing_url AS ReadOnlyRoutingURL,
        HADR.role_desc AS NodeRole
    FROM 
        sys.availability_groups AS AG
    JOIN 
        sys.availability_replicas AS AR ON AG.group_id = AR.group_id
    LEFT JOIN 
        sys.dm_hadr_availability_replica_states AS HADR 
        ON AR.replica_id = HADR.replica_id
)

-- Query to gather system-level settings and compare across replicas
SELECT 
    SERVERPROPERTY('MachineName') AS ServerName,
    SERVERPROPERTY('IsClustered') AS IsClustered,
    SERVERPROPERTY('ProductVersion') AS SQLVersion,
    SERVERPROPERTY('ProductLevel') AS SQLProductLevel,
    SERVERPROPERTY('Edition') AS SQLEdition,
    SERVERPROPERTY('IsHadrEnabled') AS IsHadrEnabled,
    SERVERPROPERTY('ProcessID') AS SQLProcessID,
    SERVERPROPERTY('NumProcessors') AS NumberOfProcessors,
    (SELECT value_in_use FROM sys.configurations WHERE name = 'max server memory (MB)') AS MaxServerMemory_MB,
    cs.cpu_count AS TotalCPUCount,
    cs.hyperthread_ratio AS HyperthreadRatio,
    qs.cluster_name AS ClusterName,
    qs.quorum_type_desc AS QuorumType,
    qs.quorum_state_desc AS QuorumState,
    AG_Config.AvailabilityGroupName,
    AG_Config.ReplicaServerName,
    AG_Config.NodeRole,
    AG_Config.AvailabilityMode,
    AG_Config.FailoverMode,
    AG_Config.SessionTimeout,
    AG_Config.PrimaryRoleConnections,
    AG_Config.SecondaryRoleConnections,
    AG_Config.BackupPriority,
    AG_Config.ReadOnlyRoutingURL
FROM 
    sys.dm_os_sys_info AS cs
CROSS JOIN 
    sys.dm_hadr_cluster AS qs
LEFT JOIN 
    AG_Config ON SERVERPROPERTY('MachineName') = AG_Config.ReplicaServerName
ORDER BY 
    ServerName;
