with const as (
select 'SPVRC3RHFD58B2PY1HZD2V71THPW7G445WBRCQYW.octopus_v01' as locker_stackswap
    -- ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k' as contract_stackswap
    ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null' as token_wstx -- 6D
    ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c::lbtc' as token_lbtc -- 8D
    ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw' as token_stsw -- 6D
    ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.vstsw-token-v1k::vstsw' as token_vstsw -- 6D
)

, tokens as (
select contract_id
, (properties ->> 'name') name
, (properties ->> 'symbol') symbol
, (properties ->> 'decimals') :: numeric decimals
, power(10, (properties ->> 'decimals') :: numeric) base
from token_properties
cross join const
where contract_id in (token_lbtc, token_stsw, token_vstsw)
)

, supply as (
with credit as (
select fx.asset_identifier, recipient as address
, sum(amount) as amount
from tokens tk
join ft_events fx on (fx.asset_identifier = tk.contract_id)
group by 1,2
)
, balance as (
select cr.asset_identifier, cr.address
, cr.amount - coalesce(debit.amount,0) as amount
from credit cr
left join lateral (
    select sum(fx.amount) as amount from ft_events fx
    where fx.asset_identifier = cr.asset_identifier
    and fx.sender = cr.address
) debit ON TRUE
)
select asset_identifier
, count(*) as users
, count(*) filter (where amount > 0) as holders
, sum(amount) as supply
from balance
join tokens on (contract_id = asset_identifier)
where address is not null
group by 1
)

, weighted as (
-- average price & liquidity over last N blocks
select avg( stsw_stx.balance_x/1e6 ) as liq_stsw
, avg( lbtc_stx.balance_x/1e8 + lbtc_stsw.balance_x/1e8 * stsw_stx.balance_x / stsw_stx.balance_y ) as liq_lbtc
, avg( stsw_stx.balance_x / stsw_stx.balance_y :: numeric ) as price_stsw
, avg( ( lbtc_stx.balance_x/1e8 + lbtc_stsw.balance_x/1e8 * stsw_stx.balance_x / stsw_stx.balance_y ) 
    / ( lbtc_stx.balance_y/1e8 + lbtc_stsw.balance_y/1e8 ) ) as price_lbtc
-- , sum(amount)/1e8 as volume
from blocks b
cross join last_block b0
cross join const
join dex.swap_balances stsw_stx on (stsw_stx.token_x = token_wstx and stsw_stx.token_y = token_stsw
    and stsw_stx.block_height = b.block_height)
left join dex.swap_balances lbtc_stx on (lbtc_stx.token_x = token_wstx and lbtc_stx.token_y = token_lbtc
    and lbtc_stx.block_height = b.block_height)
left join dex.swap_balances lbtc_stsw on (lbtc_stsw.token_x = token_stsw and lbtc_stsw.token_y = token_lbtc
    and lbtc_stsw.block_height = b.block_height)
where 0 < (lbtc_stx.balance_y + lbtc_stsw.balance_y)
and b.block_height > b0.block_height - 10
)

, liquidity as (
    select token_stsw as token, price_stsw as price, liq_stsw as liquidity
    from weighted cross join const
union all
    select token_lbtc as token, price_lbtc as price, liq_lbtc as liquidity
    from weighted cross join const
)

select split_part(contract_id,'::',1) as "Explorer"
, name, symbol, decimals
, users, holders
, to_char(supply / base, 'fm999G999G999G999G999D999') as "Circulating Supply"
, (supply / base * price) as "Market Cap (STX)"
, liquidity as "Liquidity (STX)"
from tokens
left join liquidity on (contract_id = token)
left join supply on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
