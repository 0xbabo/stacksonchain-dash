with const as (
select 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null' as token_wstx -- 6D
    , 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw' as token_stsw -- 6D
    , 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c::lbtc' as token_lbtc -- 8D
)

, weighted as (
select b.block_height, block_time
, ( lbtc_stx.balance_x/1e8 + lbtc_stsw.balance_x/1e8 * stsw_stx.balance_x / stsw_stx.balance_y ) 
    / ( lbtc_stx.balance_y/1e8 + lbtc_stsw.balance_y/1e8 ) as price
-- , sum(amount)/1e8 as volume
from blocks b
cross join const
join dex.swap_balances stsw_stx on (stsw_stx.token_x = token_wstx and stsw_stx.token_y = token_stsw
    and stsw_stx.block_height = b.block_height)
left join dex.swap_balances lbtc_stx on (lbtc_stx.token_x = token_wstx and lbtc_stx.token_y = token_lbtc
    and lbtc_stx.block_height = b.block_height)
left join dex.swap_balances lbtc_stsw on (lbtc_stsw.token_x = token_stsw and lbtc_stsw.token_y = token_lbtc
    and lbtc_stsw.block_height = b.block_height)
where 0 < (lbtc_stx.balance_y + lbtc_stsw.balance_y)
)

select to_char( date_bin(
    CASE WHEN block_time > now() - interval '7 days' THEN interval '1 hours' ELSE interval '24 hours' END
    , block_time, '2021-01-03')
    , 'YYYY-MM-DD"T"HH24"h"') as interval
, max(wp.price) as price_max
, min(wp.price) as price_min
, avg(wp.price) as price_avg
-- , volume
from weighted wp
group by 1
order by 1
