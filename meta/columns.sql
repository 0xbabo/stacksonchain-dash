SELECT table_schema, table_name, column_name, ordinal_position, data_type, udt_name,
    character_maximum_length, character_octet_length, numeric_precision, numeric_precision_radix, datetime_precision
FROM information_schema.columns
where table_schema != 'pg_catalog' and table_schema != 'information_schema'
order by table_schema, table_name, ordinal_position
