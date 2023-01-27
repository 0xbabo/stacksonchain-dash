SELECT catalog_name
, pg_size_pretty( pg_database_size('stacks_blockchain_api') ) as pg_db_size
, version() as version
from information_schema.information_schema_catalog_name
