with const as ( select
    'SM2MARAVW6BEJCD13YV2RHGYHQWT7TDDNMNRB1MVT' as miawallet,
    'SM18VBF2QYAAHN57Q28E2HSM15F6078JZYZ2FQBCX' as nycwallet,
    'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-core-v2' as core_mia_v2,
    'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-core-v1' as core_mia_v1,
    'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2' as core_nyc_v2,
    'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-core-v1' as core_nyc_v1,
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as ft_wstx,
    'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin' as ft_mia_v2,
    'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token::miamicoin' as ft_mia_v1,
    'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2::newyorkcitycoin' as ft_nyc_v2,
    'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token::newyorkcitycoin' as ft_nyc_v1
)

, props as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    cross join const
    where contract_id in (
        ft_wstx, ft_mia_v2, ft_nyc_v2, ft_mia_v1, ft_nyc_v1
    )
)

, events as (
    select
        ft.asset_event_type,
        p.contract_id as token,
        ft.sender,
        ft.recipient,
        ft.amount / p.base as amount
    from ft_events ft
    cross join const
    right join props p on (p.contract_id = ft.asset_identifier)
    join transactions tx using (tx_id)
    -- where sender in (miawallet, nycwallet)
    --     or recipient in (miawallet, nycwallet)
    -- where tx.contract_call_contract_id in (
    --     core_mia_v2, core_nyc_v2, core_mia_v1, core_nyc_v1
    -- )
union all
    select
        ft.asset_event_type,
        p.contract_id as token,
        ft.sender,
        ft.recipient,
        ft.amount / p.base as amount
    from stx_events ft
    cross join const
    right join props p on (p.contract_id = ft_wstx)
    join transactions tx using (tx_id)
    -- where sender in (miawallet, nycwallet)
    --     or recipient in (miawallet, nycwallet)
    -- where tx.contract_call_contract_id in (
    --     core_mia_v2, core_nyc_v2, core_mia_v1, core_nyc_v1
    -- )
)

, base as (
    select
      token as token,
      recipient as address,
      amount as amount
    from events
    cross join const
    where asset_event_type in ('mint', 'transfer')
    -- and recipient in (miawallet, nycwallet)
union all
    select
      token as token,
      sender as address,
      -amount as amount
    from events
    cross join const
    where asset_event_type in ('transfer', 'burn')
    -- and sender in (miawallet, nycwallet)
)

select
    -- bns||'.'||namespace as account,
    address,
    -- token,
    sum(amount) as holding
from base
cross join const
-- left join stxop.bns_address using (address)
-- where address in (miawallet, nycwallet)
-- where token = ft_wstx
where address in (
    miawallet, nycwallet, core_mia_v2, core_nyc_v2, core_mia_v1, core_nyc_v1
)
and token = ft_wstx
group by 1
order by 1 asc
