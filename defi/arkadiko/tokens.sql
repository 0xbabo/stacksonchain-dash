with const as (
select 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1' as contract_arkadiko
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as token_wstx -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda' as token_usda -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko' as token_diko -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.stdiko-token::stdiko' as token_stdiko -- 6D
)

, tokens as (
select contract_id
, (properties ->> 'name') name
, (properties ->> 'symbol') symbol
, (properties ->> 'decimals') :: numeric decimals
, power(10, (properties ->> 'decimals') :: numeric) base
from token_properties
cross join const
where contract_id in (token_usda, token_diko, token_stdiko)
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
select null as liq_usda
, avg( stx_usda.balance_x / stx_usda.balance_y :: numeric * diko_usda.balance_y / 1e6 ) as liq_diko
, avg( stx_usda.balance_x / stx_usda.balance_y :: numeric ) as price_usda
, avg( stx_usda.balance_x / stx_usda.balance_y :: numeric * diko_usda.balance_y / diko_usda.balance_x ) as price_diko
-- , sum(amount)/1e6 as volume
from blocks b
cross join last_block b0
cross join const
join dex.swap_balances stx_usda on (stx_usda.token_x = token_wstx and stx_usda.token_y = token_usda
    and stx_usda.block_height = b.block_height)
left join dex.swap_balances diko_usda on (diko_usda.token_x = token_diko and diko_usda.token_y = token_usda
    and diko_usda.block_height = b.block_height)
where 0 < (stx_usda.balance_y)
and b.block_height > b0.block_height - 10
)

, liquidity as (
    select token_usda as token, price_usda as price, null as liquidity
    from weighted cross join const
union all
    select token_diko as token, price_diko as price, liq_diko as liquidity
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
