{% macro clone_tables(source_schemas, source_database=target.database, destination_database=target.database) %}
{% if execute %}

    {{ log("started running macro clone_tables" , info=False) }}

    {% if source_database and source_schemas and destination_database %}

        {% for source_schema in source_schemas %}

            {{ log("now cloning " ~ source_database ~ "." ~ source_schema ~ 
            " into " ~ destination_database ~ "." ~ source_schema, info=False) }}
            
            {% set destination_schema = source_schema %}

            {% set get_tables_query %}
                SHOW TABLES IN {{ source_database }}.{{ source_schema }}
            {% endset %}

            {% set source_tables = run_query(get_tables_query) %}
            {% set results = [] %}

            {% for tmp_table in source_tables %}

                {% set source_table = tmp_table[1] %}

                {% call statement('clone_table', fetch_result=True, auto_begin=False) -%}
                    CREATE OR REPLACE TABLE {{ destination_database }}.{{ destination_schema }}.{{ destination_table }} 
                    CLONE {{ source_database }}.{{ source_schema }}.{{ source_table }}
                {%- endcall %}
                
                {%- set result = load_result('clone_table') -%}
                {{ log(destination_database ~ '.' ~ destination_schema ~ ', ' ~ result['data'][0][0], info=True)}}

                {% call statement('truncate_table', fetch_result=True, auto_begin=False) -%}
                    TRUNCATE TABLE IF EXISTS {{ destination_database }}.{{ destination_schema }}.{{ destination_table }}
                {%- endcall %}

                {%- set result = load_result('truncate_table') -%}
                {{ log(destination_database ~ '.' ~ destination_schema ~ ', ' ~ result['data'][0][0], info=True)}}

            {% endfor %}

        {% endfor %}

    {% else %}
        
        {{ exceptions.raise_compiler_error("Invalid arguments. Missing source and/or destination details") }}

    {% endif %}

    {{ log("finished running macro clone_tables", info=False) }}

{% endif %}
{% endmacro %}