select date_bin('1 hour', tx.block_time, b1.block_time + interval '30 min') as block_time
, count(*) filter (where fee_rate/1e3/length(raw_tx)>1.0 and 1e9>=fee_rate/1e3/length(raw_tx)) as "1.0->inf mSTX/byte"
, count(*) filter (where fee_rate/1e3/length(raw_tx)>0.4 and 1.0>=fee_rate/1e3/length(raw_tx)) as "0.4->1.0 mSTX/byte"
, count(*) filter (where fee_rate/1e3/length(raw_tx)>0.1 and 0.4>=fee_rate/1e3/length(raw_tx)) as "0.1->0.4 mSTX/byte"
, count(*) filter (where fee_rate/1e3/length(raw_tx)>0.0 and 0.1>=fee_rate/1e3/length(raw_tx)) as "0.0->0.1 mSTX/byte"
from txs tx
cross join last_block b1
where tx.block_time > b1.block_time - interval '7 days'
and fee_rate > 0
group by 1
order by 1
