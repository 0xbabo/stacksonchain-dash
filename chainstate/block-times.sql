with base2 as (
with base1 as (
select distinct t.block_height
, extract(epoch from t.block_time) as block_time
from blocks t where t.block_height>1
)
select b2.block_height
, (b2.block_time - b1.block_time)/60 as block_duration
from base1 b1
join base1 b2 on (b1.block_height = b2.block_height-1)
)

select block_height - mod(block_height,500) as block_height
, PERCENTILE_CONT(1.00) within group (order by block_duration) as "Max"
, PERCENTILE_CONT(0.75) within group (order by block_duration) as "Q3"
, avg(block_duration) as "Mean"
, 10 as "Target"
, PERCENTILE_CONT(0.50) within group (order by block_duration) as "Median"
, PERCENTILE_CONT(0.25) within group (order by block_duration) as "Q1"
, PERCENTILE_CONT(0.00) within group (order by block_duration) as "Min"
, 0 as "Zero"
from base2 b 
group by 1
order by 1
