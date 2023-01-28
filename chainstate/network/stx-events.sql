with tx as (
select block_height
, count(*) as count
from transactions group by 1
)

, nx as (
select block_height
, count(*) as count
from nft_events group by 1
)

, fx as (
select block_height
, count(*) as count
from ft_events group by 1
)

, sx as (
select block_height
, count(*) as count
, sum(amount) as amount
from stx_events group by 1
)

select date_bin('7 days', block_time, '2021-01-03')::date as block_time
, sum(sx.count) as stx_events
, sum(sx.amount)/1e6/1e3 as "STX Vol (kSTX)"
, sum(fx.count) as ft_events
, sum(nx.count) as nft_events
, sum(tx.count) as txs
from blocks bx
left join tx using (block_height)
left join sx using (block_height)
left join nx using (block_height)
left join fx using (block_height)
where block_height > 1
group by 1
