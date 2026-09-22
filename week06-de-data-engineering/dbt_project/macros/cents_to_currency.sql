{#
    Hafta 6 — örnek macro
    Kullanım: {{ cents_to_currency('amount') }}
    dbt'de tekrar eden SQL kalıplarını fonksiyon gibi paketlemenin yolu budur.
#}
{% macro cents_to_currency(column_name) %}
    ({{ column_name }} / 100.0)
{% endmacro %}
