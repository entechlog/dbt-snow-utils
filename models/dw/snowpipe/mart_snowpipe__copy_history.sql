{{ config(
    alias = 'snowpipe__copy_history',
    materialized = 'incremental',
    unique_key='record_id',
    transient=false,
    tags=["mart","snowpipe"],
    cluster_by=['load_date','table_name'],
    on_schema_change='sync_all_columns'
    ) }}

WITH source
AS (
	SELECT *
	FROM {{ ref('stg_snowpipe__copy_history') }}
    {% if is_incremental() %}
        WHERE LOAD_DATE = {% if var("filter_by_date") is not none %} {{ "'" ~ var("filter_by_date") ~ "'" }} {% else %} CURRENT_DATE() {% endif %}
    {% endif %}
	)
    
SELECT *
FROM source
