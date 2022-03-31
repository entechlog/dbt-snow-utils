{{ config(
    alias = 'snowflake__query_history',
    materialized = 'view',
    tags=["presentation","snowflake","hourly"]
    ) }}

WITH source
AS (
	SELECT {{ dbt_utils.star(ref('mart_snowflake__query_history')) }}
	FROM {{ ref('mart_snowflake__query_history') }}
	)

SELECT *
FROM source