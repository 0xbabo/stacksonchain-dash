with const as (
select 'SM2MARAVW6BEJCD13YV2RHGYHQWT7TDDNMNRB1MVT' as miawallet
, 'SM18VBF2QYAAHN57Q28E2HSM15F6078JZYZ2FQBCX' as nycwallet
, 'SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.ccd002-treasury-%-stacking' as dao_treasury_pattern
, 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-core-v2' as core_mia_v2
, 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-core-v1' as core_mia_v1
, 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2' as core_nyc_v2
, 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-core-v1' as core_nyc_v1
, 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as ft_wstx
, 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin' as ft_mia_v2
, 'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token::miamicoin' as ft_mia_v1
, 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2::newyorkcitycoin' as ft_nyc_v2
, 'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token::newyorkcitycoin' as ft_nyc_v1
)

, token_props as (
select contract_id as asset_identifier
, (properties ->> 'name') name
, (properties ->> 'symbol') symbol
, (properties ->> 'decimals') :: numeric decimals
, power(10, (properties ->> 'decimals') :: numeric) base
from token_properties
cross join const
where contract_id in (ft_mia_v2, ft_nyc_v2, ft_mia_v1, ft_nyc_v1)
)

, token_prices as (
select distinct on (token) token, price
from prices.dex_tokens_stx
where ts > now() - interval '1 day'
order by token, ts desc
)

, credit as (
select recipient as address
, asset_identifier
, base
, sum(fx.amount) as amount
from ft_events fx
join token_props using (asset_identifier)
cross join const
where recipient like ANY(
ARRAY[ dao_treasury_pattern
, core_mia_v2, core_mia_v1
, core_nyc_v2, core_nyc_v1
])
group by 1,2,3
)

select address as "Explorer"
, split_part(address,'.',2) as address
, split_part(cred.asset_identifier,'.',2) as asset_id
, to_char(cred.amount/base - coalesce(deb.amount,0)/base, '999G999G999G999D999') as amount
-- , (cred.amount/base - coalesce(deb.amount,0)/base) * dex.price as "value (STX)"
from credit cred
left join lateral (
    select sum(amount) as amount from ft_events fx
    where fx.asset_identifier = cred.asset_identifier
    and fx.sender = cred.address
) deb ON TRUE
-- left join token_prices dex on (dex.token = cred.asset_identifier)
-- order by 5 desc
order by 3,2
