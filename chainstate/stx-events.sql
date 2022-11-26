with tx as (
    select block_height, count(*) as amount
    from transactions group by 1
)

, sx as (
    select block_height, sum(amount::numeric) as amount
    from stx_events group by 1
)

, nx as (
    select block_height, count(*) as amount
    from nft_events group by 1
)

, fx as (
    select block_height, count(*) as amount
    from ft_events group by 1
)

select date_bin('7 days', block_time, '2021-01-03')::date as block_time
, sum(tx.amount) as txs
, sum(sx.amount)/1e9 as "STX Vol (kSTX)"
, sum(nx.amount) as nft_events
, sum(fx.amount) as ft_events
from blocks b
join tx using (block_height)
join sx using (block_height)
join nx using (block_height)
join fx using (block_height)
where block_height > 1
group by 1
