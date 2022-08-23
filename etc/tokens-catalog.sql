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
    where token not in (
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4ksvi3n4p1::tokensoft-token', -- XSHIB
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4k23p0pphz::tokensoft-token' -- DOGEX
    )
	order by token, ts desc
)
select name, symbol, decimals,
    to_char(supply / base, 'fm999G999G999G999G999G999D999') as "Circulating Supply",
    (supply / base * price) as "Market Cap (STX)",
    split_part(contract_id,'::',1) as "Explorer"
from tokens
left join token_prices on (contract_id = token)
left join token_supply on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
