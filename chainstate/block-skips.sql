with base2 as (
with base1 as (
select distinct block_height, burn_block_height
from blocks where block_height>1
)
select b2.block_height
, b2.burn_block_height - b1.burn_block_height - 1 as burn_blocks_missed
from base1 b1
join base1 b2 on (b1.block_height = b2.block_height-1)
)

select block_height - mod(block_height,500) as block_height
, avg(burn_blocks_missed) as avg_blocks_missed
, 0 as zero
from base2 b 
group by 1
order by 1
