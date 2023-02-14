-- with last_tx as (
-- select distinct on (sender_address) sender_address, nonce
-- from transactions tx
-- where exists (
--     select * from mempool where sender_address = tx.sender_address
-- )
-- order by sender_address, nonce desc
-- )

select date_bin('30 min', receipt_time, b1.block_time) as receipt_time
, count(*) filter (where fee_rate/1e3/pg_column_size(payload)>1.0 and 1e9>=fee_rate/1e3/pg_column_size(payload)) as "1.0->inf mSTX/byte"
, count(*) filter (where fee_rate/1e3/pg_column_size(payload)>0.4 and 1.0>=fee_rate/1e3/pg_column_size(payload)) as "0.4->1.0 mSTX/byte"
, count(*) filter (where fee_rate/1e3/pg_column_size(payload)>0.1 and 0.4>=fee_rate/1e3/pg_column_size(payload)) as "0.1->0.4 mSTX/byte"
, count(*) filter (where fee_rate/1e3/pg_column_size(payload)>0.0 and 0.1>=fee_rate/1e3/pg_column_size(payload)) as "0.0->0.1 mSTX/byte"
from mempool mem
-- left join last_tx last using (sender_address)
cross join last_block b1
where receipt_time > b1.block_time - interval '7 days'
-- and receipt_time > b1.block_time
and fee_rate > 0
-- and ((last.nonce is not null and mem.nonce > last.nonce) or (last.nonce is null and mem.nonce = 0))
group by 1
order by 1
