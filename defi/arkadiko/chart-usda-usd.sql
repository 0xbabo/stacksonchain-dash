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

select to_char( date_bin(
    CASE WHEN block_time > now() - interval '7 days' THEN interval '1 hours' ELSE interval '24 hours' END
    , block_time, '2021-01-03')
    , 'YYYY-MM-DD"T"HH24"h"') as interval
, max(stx.close * wp.price) as price_max
, min(stx.close * wp.price) as price_min
, avg(stx.close * wp.price) as price_avg
, 1 as unity
-- , avg(1/wp.price) as stx_usda
-- , avg(stx.close) as stx_usd
from weighted wp
left join prices.stx_usd stx on (timeframe = 'DAY' and ts::date = block_time::date)
where ts is not null
group by 1
order by 1
