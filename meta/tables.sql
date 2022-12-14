SELECT table_schema, table_name, column_name, ordinal_position
, table_type, is_insertable_into, data_type, udt_name
, character_maximum_length, character_octet_length
, numeric_precision, numeric_precision_radix, datetime_precision
FROM information_schema.columns
JOIN information_schema.tables USING (table_schema,table_name)
WHERE table_schema NOT IN ('information_schema','pg_catalog')
AND table_name NOT LIKE 'cache_%'
AND table_name !~ '_v[0-9]+$'
ORDER BY table_schema, table_name, ordinal_position
