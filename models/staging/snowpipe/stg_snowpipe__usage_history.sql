{{ config(
	alias = 'snowpipe__usage_history',
    schema='staging',
    materialized = 'view',
    tags=["staging","snowpipe"]
    ) }}

{% set model_id = model.unique_id | string %}

SELECT DATE (START_TIME) AS LOAD_DATE,
	{{ dbt_utils.generate_surrogate_key(['LOAD_DATE']) }} AS RECORD_ID,
	CREDITS_USED,
	BYTES_INSERTED,
	FILES_INSERTED,
	CONVERT_TIMEZONE('America/Los_Angeles', 'UTC', current_timestamp) AS CREATED_TIMESTAMP,
	'{{model_id}}' AS CREATED_BY
FROM TABLE (INFORMATION_SCHEMA.PIPE_USAGE_HISTORY(date_range_start=>dateadd({{ var('pipe_usage_history_filter_key') }}, {{ var('pipe_usage_history_filter_value') }}, CURRENT_DATE()), date_range_end=>dateadd(hour, +24, CURRENT_DATE())))
