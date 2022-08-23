with tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    where contract_id in (
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko',
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda',
        'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.wrapped-lydian-token::wrapped-lydian',
        'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.lydian-token::lydian',
        'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token::welshcorgicoin'
    )
), token_events as (
    select asset_identifier,
        sum(CASE asset_event_type WHEN 'mint' THEN amount WHEN 'burn' THEN -amount ELSE 0 END) as supply
        --sum(CASE asset_event_type WHEN 'mint' THEN amount ELSE 0 END) as mint,
        --sum(CASE asset_event_type WHEN 'burn' THEN amount ELSE 0 END) as burn
    from ft_events
    where asset_event_type in ('mint','burn')
    and asset_identifier in (select contract_id from tokens)
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
left join token_events on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
