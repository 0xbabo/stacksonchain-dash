with block_stats as (
select block_height, bx.block_time
, count(*) as txs_count
, sum(length(raw_tx)) as txs_size
from blocks bx
join txs using (block_height)
group by 1,2
order by 1
)

select date_bin('3.5 days', block_time, '2021-01-03')::date as block_time
, avg(txs_count) as "avg block txs"
, avg(txs_size)/1024 as "avg block size (kB)"
from block_stats
group by 1
order by 1
