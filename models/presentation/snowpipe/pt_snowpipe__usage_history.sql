{{ config(
    alias = 'snowpipe__usage_history',
    materialized = 'view',
    tags=["presentation","snowpipe","hourly"]
    ) }}

WITH source
AS (
	SELECT {{ dbt_utils.star(ref('mart_snowpipe__usage_history')) }}
	FROM {{ ref('mart_snowpipe__usage_history') }}
	)

SELECT *
FROM source