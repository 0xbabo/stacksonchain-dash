with const as (
select 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-%' as contract_arkadiko
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as token_wstx -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda' as token_usda -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko' as token_diko -- 6D
)

, weighted as (
select b.block_height, b.block_time
, ( diko_stx.balance_x/1e6 + diko_usda.balance_y/1e6 * stx_usda.balance_x / stx_usda.balance_y ) 
    / ( diko_stx.balance_y/1e6 + diko_usda.balance_x/1e6 ) as price
-- , sum(amount)/1e6 as volume
from blocks b
cross join const
join dex.swap_balances diko_stx on (diko_stx.token_x = token_wstx and diko_stx.token_y = token_diko
    and diko_stx.block_height = b.block_height)
left join dex.swap_balances stx_usda on (stx_usda.token_x = token_wstx and stx_usda.token_y = token_usda
    and stx_usda.block_height = b.block_height)
left join dex.swap_balances diko_usda on (diko_usda.token_x = token_diko and diko_usda.token_y = token_usda
    and diko_usda.block_height = b.block_height)
-- left join ft_events fx
where 0 < (stx_usda.balance_y)
-- group by 1,2,3
order by 1
)

select to_char( date_bin(
    CASE WHEN block_time > now() - interval '7 days' THEN interval '1 hours' ELSE interval '24 hours' END
    , block_time, '2021-01-03')
    , 'YYYY-MM-DD"T"HH24"h"') as interval
, max(wp.price) as price_max
, min(wp.price) as price_min
, avg(wp.price) as price_avg
-- , LEAST(-1.0 + coalesce(sum(volume),0) / 1e6, 1) as lerp_vol
, 0 as lerp_vol
, 0 as zero
, log(avg(price)) * 1.5 + 2.5 as log_rate
from weighted wp
group by 1
order by 1
