{% macro clone_table(source_table, destination_table, source_database=target.database, source_schema=target.schema, destination_database=target.database, destination_schema=target.schema) %}
{% if execute %}

    {{ log("started running macro clone_table" , info=False) }}

    {% if source_database and source_schema and source_table and destination_database and destination_schema and destination_table %}

        {{ log("now cloning " ~ source_database ~ "." ~ source_schema ~ "." ~ source_table ~ 
        " into " ~ destination_database ~ "." ~ destination_schema ~ destination_table, info=False) }}
        
        {% call statement('clone_table', fetch_result=True, auto_begin=False) -%}
            CREATE OR REPLACE TABLE {{ destination_database }}.{{ destination_schema }}.{{ destination_table }} 
            CLONE {{ source_database }}.{{ source_schema }}.{{ source_table }}
        {%- endcall %}
        
        {%- set result = load_result('clone_table') -%}
        {{ log(destination_database ~ '.' ~ destination_schema ~ ', ' ~ result['data'][0][0], info=True)}}

    {% else %}
        
        {{ exceptions.raise_compiler_error("Invalid arguments. Missing source and/or destination details") }}

    {% endif %}

    {{ log("finished running macro clone_table", info=False) }}

{% endif %}
{% endmacro %}