with block_diff as (
with base as (
    select distinct block_height, burn_block_height, block_time
    -- extract unix time (seconds)
    , extract(epoch from block_time) as block_epoch
    from blocks where block_height>1
)
select b2.block_height, b2.block_time
, (b2.block_epoch - b1.block_epoch)/60 as block_duration
, b2.burn_block_height - b1.burn_block_height - 1 as burn_blocks_missed
from base b1
join base b2 on (b1.block_height = b2.block_height-1)
)

select date_bin('3.5 days', block_time, '2021-01-03')::date as block_time
-- , PERCENTILE_CONT(1.00) within group (order by block_duration) as "Max"
, PERCENTILE_CONT(0.90) within group (order by block_duration) as "90pctl"
, PERCENTILE_CONT(0.75) within group (order by block_duration) as "Q3"
, avg(block_duration) as "Mean"
, 10 as "Target"
, PERCENTILE_CONT(0.50) within group (order by block_duration) as "Median"
, PERCENTILE_CONT(0.25) within group (order by block_duration) as "Q1"
, PERCENTILE_CONT(0.10) within group (order by block_duration) as "10pctl"
-- , PERCENTILE_CONT(0.00) within group (order by block_duration) as "Min"
-- , avg(burn_blocks_missed)*10 as "Blocks Missed (Per 10)"
, 0 as "Zero"
from block_diff bx
group by 1
order by 1
