{% macro delete_records_by_column(del_key, del_value, database=this.database, schema=this.schema, table=this.identifier) %}

{% if execute %}

    {%- if relation is not none -%}

        {%- call statement('delete_records_by_column_stmt', fetch_result=False, auto_begin=True) -%}
            delete from {{ database }}.{{ schema }}.{{ table }} where {{del_key}} = '{{del_value}}'
        {%- endcall -%}

    {%- endif -%}

{%- endif -%}

{% endmacro %}