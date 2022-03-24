- [Overview](#overview)
- [Installation Instructions](#installation-instructions)
- [Macro and Model Details](#macro-and-model-details)
    - [dbt_snow_utils.get_snowpipe_details](#dbt_snow_utilsget_snowpipe_details)
    - [dbt_snow_utils.clone_schema](#dbt_snow_utilsclone_schema)
      - [Arguments](#arguments)
      - [Usage](#usage)
- [Contributions](#contributions)

# Overview
This dbt package contains macros that can be (re)used across dbt projects with snowflake. 

# Installation Instructions

- Add the package into your project

  **Example** : packages.yml

  ```bash
     - git: "https://github.com/entechlog/dbt-snow-utils.git"
       revision: 0.1.0
  ```

  ```bash
     - package: entechlog/dbt_snow_utils
       version: 0.1.0
  ```

> ✅ Packages can be added to your project using either of above options  
> ✅ Please refer to the release version of this repo/dbt hub for the latest version. The version number mentioned above may not be the updated version number.

- Install the package by running below command
  
  ```bash
  dbt deps
  ```

# Macro and Model Details

### [dbt_snow_utils.get_snowpipe_details](/macros/snowpipe/get_snowpipe_details.sql)
- Snowpipe is Snowflake's continuous data ingestion service. Currently there is not a consolidated dashboard in snowflake which shows the summary of Snowpipe. 
  
- Copy history in [Snowsight](https://docs.snowflake.com/en/user-guide/ui-snowsight-gs.html#) gives a dashboard for table level copy history 
  
- Table functions `INFORMATION_SCHEMA.PIPE_USAGE_HISTORY` and `INFORMATION_SCHEMA.COPY_HISTORY` has copy history but its kept retained for 14 days

- This process materialize data from `PIPE_USAGE_HISTORY` and `COPY_HISTORY` into a snowflake table. The target tables can be used to visualize the Snowpipe copy history and usage history with the help of dbt macro `get_snowpipe_details` and dbt models with tag `+tag:snowpipe`

- To use this macro and model, [Install the package](#installation-instructions)
  
- Add the following variables under vars section of `dbt_project.yml`. This allows to customize the data retrieval filters

  ```yaml
  vars:
    dbt_snow_utils:
      pipe_databases: "ALL"
      filter_by_date: 
      pipe_copy_history_filter_key: "hours"
      pipe_copy_history_filter_value: -36
      pipe_usage_history_filter_key: "day"
      pipe_usage_history_filter_value: -2
  ```

- Add the following model configuration under models section of `dbt_project.yml`. This allows to customize the destination database and schema
  ```yaml
  models:
    dbt_snow_utils:
      staging:
        database: "DEMO_DB"
        schema: staging
      marts:
        database: "DEMO_DB"
        schema: marts
      presentation:
        database: "DEMO_DB"
        schema: presentation
  ```

- Run the models using command
  
  ```bash
  dbt run --select +tag:snowpipe --vars '{"filter_by_date": "2022-03-22"}'
  OR
  dbt run --select +tag:snowpipe
  ```

- This should create two tables `presentation.snowpipe__usage_history` and `presentation.snowpipe__copy_history` which can be integrated with BI tools to build snowpipe monitoring dashboards.

  ![](assets/img/snowpipe-monitoring-dashboard.jpg)

### [dbt_snow_utils.clone_schema](/macros/clone/clone_schema.sql)
This macro clones the source schema into the destination schema

#### Arguments
* `source_database` (required): The source database name
* `source_schema` (required): The source schema name
* `destination_database` (required): The destination database name
* `destination_postfix` (required): The destination schema name postfix

#### Usage

```
dbt run-operation dbt_snow_utils.clone_schema --args "{'source_database': 'demo_db', 'source_schemas': ['marts', 'presentation'], 'destination_database': 'demo_db', 'destination_postfix': '_20220323_01'}"
```

# Contributions
Contributions to this package are welcomed. Please create issues for bugs or feature requests for enhancement ideas or PRs for any enhancement contributions.