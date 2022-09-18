with tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    where contract_id in (
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-apower::apower',
        'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin',
        'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2::newyorkcitycoin',
        'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas::BANANA',
        'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token::SLIME'
    )
), token_events as (
    select asset_identifier,
        sum(CASE asset_event_type WHEN 'mint' THEN amount WHEN 'burn' THEN -amount ELSE 0 END) as supply
        --sum(CASE asset_event_type WHEN 'mint' THEN amount ELSE 0 END) as mint,
        --sum(CASE asset_event_type WHEN 'burn' THEN amount ELSE 0 END) as burn
    from ft_events
    join tokens on (asset_identifier = contract_id)
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
    -- TODO: liquidity, volume
from tokens
left join token_prices on (contract_id = token)
left join token_events on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
