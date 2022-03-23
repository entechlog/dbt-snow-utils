{{ config(
	alias = 'snowpipe__copy_history',
    schema='staging',
    materialized = 'view',
    tags=["staging","snowpipe"]
    ) }}

{% set pipe_details = get_snowpipe_details() %}
{% set model_id = model.unique_id | string %}

{% for pipe_detail in pipe_details %}

{%- if not loop.first %} UNION ALL {% endif %}

{% set table_full_name = pipe_detail[7] %}

SELECT DATE (LAST_LOAD_TIME) AS LOAD_DATE,
	{{ dbt_utils.surrogate_key(['FILE_NAME','STAGE_LOCATION', 'LOAD_DATE']) }} AS RECORD_ID,
	FILE_NAME,
	STAGE_LOCATION,
	LAST_LOAD_TIME,
	ROW_COUNT,
	ROW_PARSED,
	FILE_SIZE,
	FIRST_ERROR_MESSAGE,
	FIRST_ERROR_LINE_NUMBER,
	FIRST_ERROR_CHARACTER_POS,
	FIRST_ERROR_COLUMN_NAME,
	ERROR_COUNT,
	ERROR_LIMIT,
	STATUS,
	TABLE_CATALOG_NAME,
	TABLE_SCHEMA_NAME,
	TABLE_NAME,
	PIPE_CATALOG_NAME,
	PIPE_SCHEMA_NAME,
	PIPE_NAME,
	PIPE_RECEIVED_TIME,
	CONVERT_TIMEZONE('America/Los_Angeles', 'UTC', current_timestamp) AS CREATED_TIMESTAMP,
	'{{model_id}}' AS CREATED_BY
FROM TABLE (INFORMATION_SCHEMA.COPY_HISTORY(table_name => '{{table_full_name|upper}}', start_time => dateadd({{ var('pipe_copy_history_filter_key') }}, {{ var('pipe_copy_history_filter_value') }}, current_timestamp())))

{% endfor %}
