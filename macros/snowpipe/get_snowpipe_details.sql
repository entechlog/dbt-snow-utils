{% macro get_snowpipe_details() %}
{% if execute %}

{{ log(modules.datetime.datetime.now().strftime("%H:%M:%S") ~ " | started running macro get_snowpipe_details" , info=False) }}
{% set get_snowpipe_details_query %}

SHOW PIPES IN ACCOUNT;

WITH source
AS (
	SELECT $3 AS pipe_database_name,
		$4 AS pipe_schema_name,
		$2 AS pipe_name,
		TRIM(REPLACE(SPLIT(SUBSTRING(UPPER($5), CHARINDEX('INTO', UPPER($5)) + 5, LEN($5)), 'FROM') [0], '\n', '')) AS table_temp_name,
		REGEXP_COUNT(table_temp_name, '[.]') AS table_delimiter_count,
		CASE 
			WHEN table_delimiter_count = 2
				THEN SPLIT(table_temp_name, '.') [0]::string
			ELSE NULL
			END AS table_database_name,
		CASE 
			WHEN table_delimiter_count = 2
				THEN SPLIT(table_temp_name, '.') [1]::string
			WHEN table_delimiter_count = 1
				THEN SPLIT(table_temp_name, '.') [0]::string
			ELSE NULL
			END AS table_schema_name,
		CASE 
			WHEN table_delimiter_count = 2
				THEN SPLIT(table_temp_name, '.') [2]::string
			WHEN table_delimiter_count = 1
				THEN SPLIT(table_temp_name, '.') [1]::string
			ELSE table_temp_name
			END AS table_name,
		CASE 
			WHEN table_delimiter_count = 2
				THEN table_temp_name
			WHEN table_delimiter_count = 1
				THEN pipe_database_name || '.' || table_temp_name
			ELSE pipe_database_name || '.' || pipe_schema_name || '.' || table_temp_name
			END AS table_full_name,
		$6 AS pipe_owner
	FROM TABLE (result_scan(last_query_id()))
	)

SELECT pipe_owner,
	pipe_database_name,
	pipe_schema_name,
	pipe_name,
	table_database_name,
	table_schema_name,
	table_name,
	table_full_name
FROM source;

{% endset %}

{%- call statement('get_snowpipe_details_stmt', fetch_result=True) %}
    {{get_snowpipe_details_query}}
{%- endcall -%}

{%- set results = load_result('get_snowpipe_details_stmt') -%}
{{ log(modules.datetime.datetime.now().strftime("%H:%M:%S") ~ " | get_snowpipe_details results      : " ~ results['data'], info=False) }}
{{ log(modules.datetime.datetime.now().strftime("%H:%M:%S") ~ " | finished running macro get_snowpipe_details", info=False) }}
{{ return(results['data']) }}

{% endif %}
{% endmacro %}