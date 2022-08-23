with const as ( select
    'SPVRC3RHFD58B2PY1HZD2V71THPW7G445WBRCQYW.octopus_v01' as stackswap_locker
), tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    where contract_id in (
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw',
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c::lbtc',
        'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token::miamicoin',
        'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token::newyorkcitycoin',
        'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token::welshcorgicoin'
        --'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn::fari',
        --'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4ktqebauw9::tokensoft-token' -- zero
  )
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
)
select name, symbol, decimals,
    to_char(supply / base, 'fm999G999G999G999G999D999') as "Circulating Supply",
    (supply / base * price) as "Market Cap (STX)",
    split_part(contract_id,'::',1) as "Explorer"
from tokens
left join token_prices on (contract_id = token)
left join token_supply on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
