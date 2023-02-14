-- Fee estimates for Gamma BNS listing (~4700 byte contract deployment tx), by mempool analysis.

with const as (
select min(fee_rate/length(raw_tx)) as min_fee_rate
from txs
where block_height > get_max_block() - 10
and fee_rate > 0
)

, last_tx as (
select distinct on (sender_address) sender_address, nonce
from transactions tx
where exists (
    select * from mempool where sender_address = tx.sender_address
)
order by sender_address, nonce desc
)

select to_char(min_fee_rate * 4700/1e6, '990D999999') as "Casual"
, to_char( PERCENTILE_CONT(0.10) within group (order by fee_rate/pg_column_size(payload)) * 4700/1e6
    , '990D999999') as "Normal"
, to_char( PERCENTILE_CONT(0.50) within group (order by fee_rate/pg_column_size(payload)) * 4700/1e6
    , '990D999999') as "Fast"
, to_char(avg(fee_rate/pg_column_size(payload)) * 4700/1e6, '990D999999') as "Rush"
-- , count(*)
from mempool mem
join last_tx confirmed using (sender_address)
cross join const
where receipt_time > now() - interval '6 hours'
and (mem.nonce > confirmed.nonce or mem.nonce = 0) -- ignore txs with invalid nonce
group by min_fee_rate
