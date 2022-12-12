SELECT ns.nspname as schema, p.proname as function, oidvectortypes(p.proargtypes) as args
FROM pg_proc p INNER JOIN pg_namespace ns ON (p.pronamespace = ns.oid)
WHERE ns.nspname != 'pg_catalog' and ns.nspname != 'information_schema'
order by 1,2
