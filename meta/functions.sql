SELECT routine_schema, routine_name, routine_type, data_type, oidvectortypes(p.proargtypes) as pg_args
, routine_body, external_name, external_language, parameter_style, is_deterministic
, sql_data_access, security_type
FROM information_schema.routines
JOIN pg_proc p ON (p.proname = routine_name)
JOIN pg_namespace ns ON (p.pronamespace = ns.oid AND routine_schema = ns.nspname)
WHERE routine_schema NOT IN ('information_schema','pg_catalog')
ORDER BY 1,2