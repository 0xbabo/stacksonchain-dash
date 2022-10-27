with block_diff as (
with base as (
    select distinct block_height, burn_block_height
    -- extract unix time (seconds)
    , extract(epoch from block_time) as block_time
    from blocks where block_height>1
)
select b2.block_height
, (b2.block_time - b1.block_time)/60 as block_duration
, b2.burn_block_height - b1.burn_block_height - 1 as burn_blocks_missed
from base b1
join base b2 on (b1.block_height = b2.block_height-1)
)

, block_stats as (
    select distinct on (block_height) 
        block_height, bx.block_time, block_duration, burn_block_height, burn_blocks_missed
        , sum(parent_microblock_sequence) as parent_microblock_sequence
        , sum(reward_amount) as reward_amount
        , count(*) as txs_num
        , sum(length(raw_tx)) as txs_size
        , sum(fee_rate) as fees
    from blocks bx
    join block_diff using (block_height)
    join burnchain_rewards burn using (burn_block_height)
    join txs tx using (block_height)
    -- join stx_events sx on (block_height)
    -- where bx.block_time > now() - interval '1 month'
    group by 1,2,3,4,5
    order by 1
)

select date_bin('3.5 days', bs.block_time, date_trunc('month',now())) as time
, count(*)/3.5 as "avg blocks/day"
, avg(txs_num) as "avg block txs"
, avg(txs_size)/1024 as "avg block size (kB)"
, avg(fees)/1e6 as "avg block fees (STX)"
, avg(burn_blocks_missed)*100 as "avg blocks missed (%)"
, avg(txs_size / txs_num)/10 as "avg tx size (10bytes)"
-- , sum(reward_amount)/1e6 as rewards
from block_stats bs
group by 1
order by 1
-- limit 1000
