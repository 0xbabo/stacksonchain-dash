with tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    where contract_id in (
        'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-Bitcoin::wrapped-bitcoin',
        'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-USD::wrapped-usd'
    )
), token_supply as (
    select asset_identifier,
        sum(CASE WHEN asset_event_type = 'mint' THEN amount ELSE 0 END) as minted,
        sum(CASE WHEN asset_event_type = 'burn' THEN amount ELSE 0 END) as burned
    from ft_events
    join tokens on (asset_identifier = contract_id)
    group by 1
)
select
    name, symbol, decimals,
    to_char( (minted) / base, 'fm999G999G999G999G999G999D999') as "Wrapped (Minted)",
    to_char( (burned) / base, 'fm999G999G999G999G999G999D999') as "Unwrapped (Burned)",
    to_char( (minted-burned) / base, 'fm999G999G999G999G999G999D999') as "Circulating Supply",
    split_part(contract_id,'::',1) as "Explorer"
from tokens
join token_supply on (contract_id = asset_identifier)
order by 2 asc
