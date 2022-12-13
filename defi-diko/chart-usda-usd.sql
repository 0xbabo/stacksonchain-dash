with const as (
select 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as token_wstx -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko' as token_diko -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda' as token_usda -- 6D
)

, weighted as (
select b.block_height, block_time
, p1.balance_x / p1.balance_y :: float as price
from blocks b
cross join const
join dex.swap_balances p1 on ( p1.block_height = b.block_height
    and p1.token_x = token_wstx and p1.token_y = token_usda )
where 0 < p1.balance_y
order by 1
)

select date_bin('1 day', ts, '2021-11-01') as interval
, max(su.value * wp.price) as price_max
, min(su.value * wp.price) as price_min
, avg(su.value * wp.price) as price_avg
, avg(1/wp.price) as stx_usda
, 1 as unity
, avg(su.value) as stx_usd
from weighted wp
join ts.stx_usd_1h su on (ts = date_trunc('hour',block_time))
group by 1
order by 1
