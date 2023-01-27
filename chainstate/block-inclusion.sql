with block_diff as (
with base as (
    select distinct block_height, burn_block_height, block_time
    , extract(epoch from block_time) as block_epoch -- unix time in seconds
    from blocks where block_height>1
)
select b2.block_height, b2.block_time, b2.burn_block_height
, (b2.block_epoch - b1.block_epoch)/60 as block_duration
, b2.burn_block_height - b1.burn_block_height - 1 as burn_blocks_missed
from base b1
join base b2 on (b1.block_height = b2.block_height-1)
)

-- select date_bin('3.5 days', block_time, '2021-01-03')::date as block_time
select burn_block_height - (burn_block_height - 666050) % 300 as burn_block_height
, 100.0 * count(*) / 300 as "blocks included (%)"
, avg(burn_blocks_missed)*100 as "blocks missed (%)"
from block_diff
group by 1
order by 1
