SELECT version() as "DB Version"
, pg_size_pretty( pg_database_size('stacks_blockchain_api') ) as "DB size"