- [Overview](#overview)
- [Installation Instructions](#installation-instructions)
- [Macro and Model Details](#macro-and-model-details)
    - [dbt_snow_utils.get_snowpipe_details](#dbt_snow_utilsget_snowpipe_details)
    - [dbt_snow_utils.clone_schema](#dbt_snow_utilsclone_schema)
      - [Arguments](#arguments)
      - [Usage](#usage)
        - [run-operation](#run-operation)
        - [pre_hook/post_hook](#pre_hookpost_hook)
    - [dbt_snow_utils.clone_table](#dbt_snow_utilsclone_table)
      - [Arguments](#arguments-1)
      - [Usage](#usage-1)
        - [run-operation](#run-operation-1)
        - [pre_hook/post_hook](#pre_hookpost_hook-1)
    - [dbt_snow_utils.delete_records_by_column](#dbt_snow_utilsdelete_records_by_column)
      - [Arguments](#arguments-2)
      - [Usage](#usage-2)
        - [run-operation](#run-operation-2)
        - [pre_hook/post_hook](#pre_hookpost_hook-2)
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
This macro clones the source schema/schemas into the destination database.

#### Arguments
* `source_schema` (required): The source schema name
* `destination_postfix` (required): The destination schema name postfix
* `source_database` (optional): The source database name
* `destination_database` (optional): The destination database name

#### Usage

##### run-operation
```
dbt run-operation dbt_snow_utils.clone_schema --args "{'source_database': 'demo_db', 'source_schemas': ['marts', 'presentation'], 'destination_database': 'demo_db', 'destination_postfix': '_20220323_01'}"
```

##### pre_hook/post_hook
```
pre_hook="{{ dbt_snow_utils.clone_schema(['marts', 'presentation'], '_backup', 'demo_db', this.database) }}"
```

### [dbt_snow_utils.clone_table](/macros/clone/clone_table.sql)
This macro clones the source table into the destination database/schema.

#### Arguments
* `source_table` (required): The source table name
* `destination_table` (required): The destination table name
* `source_database` (optional): The source database name
* `source_schema` (optional): The source schema name
* `destination_database` (optional): The destination database name
* `destination_schema` (optional): The destination schema name
  
#### Usage

##### run-operation
```
dbt run-operation clone_table --args '{"source_table": "COUNTRY_CODE", "destination_table": "COUNTRY_CODE_BKP"}'
```

##### pre_hook/post_hook
```
post_hook="{{ dbt_snow_utils.clone_table(this.identifier,this.identifier~'_temp', this.database, this.schema, this.database, this.schema ) }}"
```

### [dbt_snow_utils.delete_records_by_column](/macros/common/delete_records_by_column.sql)
This macro deletes data from a table based on a where clause. Often used as pre-hook in incremental loads to delete the data.

#### Arguments
* `del_key` (required): The column name in WHERE clause of deletes
* `del_value` (required): The value for column name in WHERE clause of deletes
* `database` (optional): The database name
* `schema` (optional): The schema name
* `table` (optional): The table name
  
#### Usage

##### run-operation
```
dbt run-operation delete_records_by_column --args '{"del_key": "payment_date", "del_value": "2005-05-25", "database": "DBT_DEMO", "schema": "MARTS", "table": "tmp_store_revenue"}'
```

##### pre_hook/post_hook
```
post_hook="{{ dbt_snow_utils.delete_records_by_column('payment_date', '2005-05-24') }}"

post_hook="{{ dbt_snow_utils.delete_records_by_column('payment_date', var('start_date')) }}"
```
# Contributions
Contributions to this package are welcomed. Please create issues for bugs or feature requests for enhancement ideas or PRs for any enhancement contributions.