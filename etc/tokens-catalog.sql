with const as ( select
    'SPVRC3RHFD58B2PY1HZD2V71THPW7G445WBRCQYW.octopus_v01' as stackswap_locker
), tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    --where contract_id in (...)
), token_supply as (
    select asset_identifier, sum(total) as supply from (
        select asset_identifier, sum(amount) as total
        from ft_events
        cross join const
        where asset_identifier in (select contract_id from tokens)
        and (asset_event_type in ('mint') or (
            asset_event_type in ('transfer') and sender in (stackswap_locker)
        ))
        group by 1
    union all
        select asset_identifier, sum(-amount) as total
        from ft_events
        cross join const
        where asset_identifier in (select contract_id from tokens)
        and (asset_event_type in ('burn') or (
            asset_event_type in ('transfer') and recipient in (stackswap_locker)
        ))
        group by 1
    ) sub
    group by 1
), token_prices as (
    select distinct on (token) token, price
    from prices.dex_tokens_stx
	order by token, ts desc
), token_pools as (
    select distinct on (contract_id, token_x, token_y) token_x, token_y, balance_x, balance_y
    from prices.swap_balances
    order by contract_id, token_x, token_y, block_height desc
), token_liquidity as (
    select tk.contract_id,
        sum(CASE WHEN tk.contract_id = token_x THEN balance_x ELSE balance_y END / tky.base * tk.base) as liquidity
    from tokens tk
    left join token_pools on (tk.contract_id in (token_x, token_y))
    left join tokens tky on (tky.contract_id = token_y) -- balances both use decimals from token_y
    group by tk.contract_id
)
select name, symbol, decimals,
    to_char(supply / base, 'fm999G999G999G999G999G999D999') as "Circulating Supply",
    (supply / base * price) as "Market Cap (STX)",
    (liquidity / base * price) as "Liquidity (STX)",
    split_part(contract_id,'::',1) as "Explorer"
from tokens
left join token_prices on (contract_id = token)
left join token_supply on (contract_id = asset_identifier)
left join token_liquidity using (contract_id)
order by (CASE WHEN liquidity/base*price > 1000 THEN supply/base*price ELSE liquidity/base*price END) desc nulls last
