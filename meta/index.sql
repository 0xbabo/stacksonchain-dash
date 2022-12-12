SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname != 'pg_catalog'
ORDER BY 1,2,3
