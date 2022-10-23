with block_stats as (
    select distinct on (block_height) 
        block_height, burn_block_height, bx.block_time
        , sum(parent_microblock_sequence) as parent_microblock_sequence
        , sum(reward_amount) as reward_amount
        , count(*) as txs_num
        , sum(length(raw_tx)) as txs_size
        , sum(fee_rate) as fees
    from blocks bx
    join burnchain_rewards burn using (burn_block_height)
    join txs tx using (block_height)
    -- where bx.block_time > now() - interval '1 month'
    group by 1, 2, 3
    order by 1
)

select date_bin('3.5 days', bs.block_time, date_trunc('month',now())) as time
, count(*)/3.5 as "avg blocks/day"
, avg(txs_num) as "avg block txs"
, avg(txs_size)/1024 as "avg block size (kB)"
, avg(fees)/1e6 as "avg block fees (STX)"
-- , sum(reward_amount)/1e6 as rewards
from block_stats bs
-- join txs tx using (block_height)
-- join stx_events sx on (block_height)
group by 1
order by 1
-- limit 1000
