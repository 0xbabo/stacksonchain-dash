with const as ( select
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex' as the_asset
)

, props as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    -- where contract_id in (...)
)

, events as (
  select
    ft.asset_event_type,
    ft.asset_identifier as token,
    ft.sender,
    ft.recipient,
    ft.amount / p.base as amount
  from FT_EVENTS ft
  join transactions tx using (tx_id)
  join props p on (p.contract_id = ft.asset_identifier)
  cross join const
  where tx.status = 1 and asset_identifier = the_asset
)

, base as (
    select
      token as token,
      recipient as address,
      amount as amount
    from events
    where asset_event_type = 'mint' or asset_event_type = 'transfer'
    
    union all
    
    select
      token as token,
      sender as address,
      -amount as amount
    from events
    where asset_event_type = 'burn' or asset_event_type = 'transfer'
)

select
  address,
  sum(amount) as holding
from base
group by address
order by holding desc
limit 50
