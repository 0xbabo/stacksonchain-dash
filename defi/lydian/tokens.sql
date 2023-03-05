with const as (
select 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-v2-1' as contract_arkadiko
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as token_wstx -- 6D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda' as token_usda -- 6D
    , 'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.lydian-token::lydian' as token_ldn
    , 'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.wrapped-lydian-token::wrapped-lydian' as token_wldn
)

, tokens as (
select contract_id
, (properties ->> 'name') name
, (properties ->> 'symbol') symbol
, (properties ->> 'decimals') :: numeric decimals
, power(10, (properties ->> 'decimals') :: numeric) base
from token_properties
cross join const
where contract_id in (token_ldn, token_wldn)
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
select null as liq_wldn
, avg( stx_usda.balance_x / stx_usda.balance_y :: numeric * ldn_usda.balance_y / 1e6 ) as liq_ldn
, null as price_wldn
, avg( stx_usda.balance_x / stx_usda.balance_y :: numeric * ldn_usda.balance_y / ldn_usda.balance_x ) as price_ldn
-- , sum(amount)/1e6 as volume
from blocks b
cross join last_block b0
cross join const
join dex.swap_balances stx_usda on (stx_usda.token_x = token_wstx and stx_usda.token_y = token_usda
    and stx_usda.block_height = b.block_height)
left join dex.swap_balances ldn_usda on (ldn_usda.token_x = token_ldn and ldn_usda.token_y = token_usda
    and ldn_usda.block_height = b.block_height)
-- left join ft_events fx
where 0 < (stx_usda.balance_y)
and b.block_height > b0.block_height - 10
)

, liquidity as (
    select token_ldn as token, price_ldn as price, liq_ldn as liquidity
    from weighted cross join const
union all
    select token_wldn as token, null as price, null as liquidity
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
