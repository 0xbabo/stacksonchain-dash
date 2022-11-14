with const as (
select 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as token_wstx_diko -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko' as token_diko -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda' as token_usda -- 6D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx::wstx' as token_wstx_alex -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex' as token_alex -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wusda::wusda' as token_usda_alex -- 8D
    , 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null' as token_wstx_stsw -- 6D
    , 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw' as token_stsw -- 6D
    , 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c::lbtc' as token_lbtc -- 8D
)

, weighted as (
select b.block_height, b.block_time
, pool_diko.balance_y / pool_diko.balance_x :: float as price_diko
, pool_stsw.balance_y / pool_stsw.balance_x :: float as price_stsw
, (pool_alex_gov.balance_y / pool_alex_gov.balance_x :: float) * (pool_alex_stx.balance_y / pool_alex_stx.balance_x :: float) as price_alex
from blocks b
cross join const
join dex.swap_balances pool_diko on (pool_diko.token_x = token_wstx_diko and pool_diko.token_y = token_usda
    and pool_diko.block_height = b.block_height and pool_diko.balance_x > 0)
left join dex.swap_balances pool_stsw on (pool_stsw.token_x = token_wstx_stsw and pool_stsw.token_y = token_usda
    and pool_stsw.block_height = b.block_height and pool_stsw.balance_x > 0)
left join dex.swap_balances pool_alex_gov on (pool_alex_gov.token_x = token_alex and pool_alex_gov.token_y = token_usda_alex
    and pool_alex_gov.block_height = b.block_height and pool_alex_gov.balance_x > 0)
left join dex.swap_balances pool_alex_stx on (pool_alex_stx.token_x = token_wstx_alex and pool_alex_stx.token_y = token_alex
    and pool_alex_stx.block_height = b.block_height and pool_alex_stx.balance_x > 0)
where b.block_time > now() - interval '7 days'
)

select date_bin('1 hours', block_time, '2021-11-01') as interval
, avg(coalesce(wp.price_alex / wp.price_diko, 1)) as price_alex
, 1 as unity
, avg(coalesce(wp.price_stsw / wp.price_diko, 1)) as price_stsw
from weighted wp
join ts.stx_usd_1h su on (ts = date_trunc('hour',block_time))
group by 1
order by 1
