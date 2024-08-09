# SQL-AON-Audit


![GitHub](https://img.shields.io/github/license/DBA-Pro-Mir/SQL-AON-Audit)
![GitHub last commit](https://img.shields.io/github/last-commit/DBA-Pro-Mir/SQL-AON-Audit)
![GitHub issues](https://img.shields.io/github/issues/DBA-Pro-Mir/SQL-AON-Audit)
![GitHub forks](https://img.shields.io/github/forks/DBA-Pro-Mir/SQL-AON-Audit?style=social)
![GitHub stars](https://img.shields.io/github/stars/DBA-Pro-Mir/SQL-AON-Audit?style=social)

## Overview

This repository contains a set of SQL Server scripts used for auditing and verifying the configuration of Always On Availability Groups (AON) and Windows Failover Clustering (WFCS) environments. The primary focus is to ensure that all nodes in the AON setup are configured consistently, following best practices.

## Contents

- **AON_Monthly_Configuration_Audit.sql**: A comprehensive script to audit SQL Server instances participating in AON. It checks key configurations, such as memory allocation, CPU settings, node roles (primary/secondary), failover modes, and quorum settings.

  
-  **SQL_Server_Configuration_Check.sql** : This script is designed to gather critical SQL Server configuration settings for each instance. This script helps administrators audit and review key configuration options such as memory settings, CPU settings, parallelism, and worker threads to ensure consistency across the environment.

  
-   **Current_Server_Settings_Audit.sql** : This script retrieves critical system-level information about the current settings of the SQL Server instance. 
It includes details on memory usage, locked pages, large pages allocation, and SQL Server services status. This script is useful for regular auditing and ensuring that server configurations are optimal and consistent with best practices.


- **Additional Scripts**: Future scripts will be added to extend the auditing capabilities, including security checks, performance baselines, and disaster recovery readiness.

## Usage

1. **Run Frequency**: The primary script should be executed monthly as part of routine maintenance.
2. **Execution**: Run the script on each SQL Server instance that is part of your Always On Availability Group setup.
3. **Results**: Review and compare the results across all nodes to ensure consistency and detect any discrepancies in configuration.

## Contributions

Contributions are welcome! Please submit a pull request or open an issue to suggest improvements or report problems.

## License

This repository is licensed under the [MIT License](LICENSE).

