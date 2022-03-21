{{ config(
    alias = 'snowpipe__copy_history',
    materialized = 'view',
    tags=["presentation","snowpipe","hourly"]
    ) }}

WITH source
AS (
	SELECT {{ dbt_utils.star(ref('mart_snowpipe__copy_history')) }}
	FROM {{ ref('mart_snowpipe__copy_history') }}
	)

SELECT *
FROM source