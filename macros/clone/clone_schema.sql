{% macro clone_schema(source_database, source_schemas, destination_database, destination_postfix) %}
{% if execute %}

    {{ log("started running macro clone_schema" , info=False) }}

    {% if source_database and source_schemas and destination_database and destination_postfix %}

        {% for source_schema in source_schemas %}

        {{ log("now cloning                       : " ~ source_database ~ "." ~ source_schema ~ 
        " into " ~ destination_database ~ "." ~ source_schema ~ destination_postfix, info=True) }}
        
        {% call statement('clone_schema', fetch_result=True, auto_begin=False) -%}
            CREATE SCHEMA IF NOT EXISTS {{ destination_database }}.{{ source_schema }}{{ destination_postfix }} 
            CLONE {{ source_database }}.{{ source_schema }}
        {%- endcall %}
        
        {%- set result = load_result('clone_schema') -%}
        {{ log(result['data'][0][0], info=True)}}

        {% endfor %}

    {% else %}
        
        {{ exceptions.raise_compiler_error("Invalid arguments. Missing source and/or destination details") }}

    {% endif %}

    {{ log("finished running macro clone_schema", info=False) }}

{% endif %}
{% endmacro %}