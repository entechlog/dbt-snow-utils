{{ config(
    alias = 'snowflake__query_history',
    materialized = 'incremental',
    unique_key='query_id',
    transient=false,
    tags=["mart","snowflake"],
    cluster_by=['query_date','database_name','user_name'],
    on_schema_change='sync_all_columns'
    ) }}

WITH source
AS (
	SELECT *
	FROM {{ ref('stg_snowflake__query_history') }}
    {% if is_incremental() %}
        WHERE QUERY_DATE = {% if var("filter_by_date") is not none %} {{ "'" ~ var("filter_by_date") ~ "'" }} {% else %} CURRENT_DATE() {% endif %}
    {% endif %}
	)
    
SELECT *
FROM source
