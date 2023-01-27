with const as (
select 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%' as contract_alex
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx::wstx' as token_wstx -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wbtc::wbtc' as token_wbtc -- 8D
    , 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin::wrapped-bitcoin' as token_xbtc -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex' as token_alex -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex' as token_auto -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-apower::apower' as token_apower -- 8D
)

, tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    cross join const
    where contract_id in (token_alex, token_auto, token_apower, token_xbtc)
)

, supply as (
select asset_identifier, sum(total) as supply from (
    select asset_identifier, sum(amount) as total
    from ft_events
    cross join const
    right join tokens on (contract_id = asset_identifier)
    where (sender is null)
    group by 1
union all
    select asset_identifier, sum(-amount) as total
    from ft_events
    cross join const
    right join tokens on (contract_id = asset_identifier)
    where (recipient is null)
    group by 1
) sub
group by 1
)

, weighted as (
-- average price & liquidity over last N blocks
select null as liq_alex
, avg( alex_stx.balance_x / alex_stx.balance_y :: numeric * auto_alex.balance_x / 1e8 ) as liq_auto
, avg( xbtc_stx.balance_x / 1e8 ) as liq_xbtc
, avg( alex_stx.balance_x / alex_stx.balance_y :: numeric ) as price_alex
, avg( alex_stx.balance_x / alex_stx.balance_y :: numeric * auto_alex.balance_x / auto_alex.balance_y ) as price_auto
, avg( xbtc_stx.balance_x / xbtc_stx.balance_y :: numeric ) as price_xbtc
-- , sum(amount)/1e6 as volume
from blocks b
cross join last_block b0
cross join const
join dex.swap_balances alex_stx on (alex_stx.token_x = token_wstx and alex_stx.token_y = token_alex
    and alex_stx.block_height = b.block_height)
left join dex.swap_balances auto_alex on (auto_alex.token_x = token_alex and auto_alex.token_y = token_auto
    and auto_alex.block_height = b.block_height)
left join dex.swap_balances xbtc_stx on (xbtc_stx.token_x = token_wstx and xbtc_stx.token_y = token_wbtc
    and xbtc_stx.block_height = b.block_height)
where 0 < (alex_stx.balance_y)
and b.block_height > b0.block_height - 10
)

, liquidity as (
    select token_alex as token, price_alex as price, null as liquidity
    from weighted cross join const
union all
    select token_auto as token, price_auto as price, liq_auto as liquidity
    from weighted cross join const
union all
    select token_xbtc as token, price_xbtc as price, liq_xbtc as liquidity
    from weighted cross join const
)

select split_part(contract_id,'::',1) as "Explorer"
, name, symbol, decimals
, to_char(supply / base, 'fm999G999G999G999G999D999') as "Circulating Supply"
, (supply / base * price) as "Market Cap (STX)"
, liquidity as "Liquidity (STX)"
from tokens
left join liquidity on (contract_id = token)
left join supply on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
