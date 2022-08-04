{% macro clone_schemas(source_schemas, destination_postfix, source_database=target.database, destination_database=target.database) %}
{% if execute %}

    {{ log("started running macro clone_schemas" , info=False) }}

    {% if source_database and source_schemas and destination_database and destination_postfix %}

        {% for source_schema in source_schemas %}

        {{ log("now cloning " ~ source_database ~ "." ~ source_schema ~ 
        " into " ~ destination_database ~ "." ~ source_schema ~ destination_postfix, info=False) }}
        
        {% call statement('clone_schemas', fetch_result=True, auto_begin=False) -%}
            CREATE OR REPLACE SCHEMA {{ destination_database }}.{{ source_schema }}{{ destination_postfix }} 
            CLONE {{ source_database }}.{{ source_schema }}
        {%- endcall %}
        
        {%- set result = load_result('clone_schemas') -%}
        {{ log(destination_database ~ ', ' ~ result['data'][0][0], info=True)}}

        {% endfor %}

    {% else %}
        
        {{ exceptions.raise_compiler_error("Invalid arguments. Missing source and/or destination details") }}

    {% endif %}

    {{ log("finished running macro clone_schemas", info=False) }}

{% endif %}
{% endmacro %}