select cycle
, count(distinct locked_address) as users
, count(distinct tx_id) as txs
, count(distinct sender_address) as stackers
-- , count(*) as events
-- , sum(locked_amount)/1e6 as amount
from stx_lock_events lx
join transactions tx using (tx_id,block_height)
join blocks bx using (block_height)
join generate_series(1,51) cycle on (
    burn_block_height < 666050 + 2100*cycle and 666050 + 2100*cycle < unlock_height
    -- (burn_block_height-666050)/2100 < cycle and cycle < (unlock_height-666050)/2100
)
-- there are some non-canonical lock events
where lx.canonical is true
group by 1
order by 1
