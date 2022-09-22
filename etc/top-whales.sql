with const as ( select
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as ft_wstx
)

, props as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base,
        price
    from token_properties
    join (
        select distinct on (token) token, price
        from prices.dex_tokens_stx
        where token not like '%soft-token%' -- tokens with problematic price data
        order by token, ts desc
    ) p on (token = contract_id)
    -- where contract_id in (...)
-- union select values(...)
)

, events as (
    select
        ft.asset_event_type,
        p.contract_id as token,
        ft.sender,
        ft.recipient,
        ft.amount / p.base * p.price as amount
    from ft_events ft
    join props p on (p.contract_id = ft.asset_identifier)
union all
    select
        ft.asset_event_type,
        p.contract_id as token,
        ft.sender,
        ft.recipient,
        ft.amount / p.base * p.price as amount
    from stx_events ft
    cross join const
    join props p on (p.contract_id = ft_wstx)
)

, base as (
    select
      recipient as address,
      token as token,
      amount as amount
    from events
    where recipient is not null
union all
    select
      sender as address,
      token as token,
      -amount as amount
    from events
    where sender is not null
)

, balances as (
    select address, token, sum(amount) as value
    from base
    group by address, token
    order by value desc
)

, top as (
    select distinct on (address) address, symbol
    from balances
    join props p on (token = p.contract_id)
    order by address, value desc
)

select
    -- bns||'.'||namespace as account,
    address as account,
    sum(value) as "Value (STX)",
    symbol as "Top Asset"
from balances
join top using (address)
-- left join stxop.bns_address using (address)
group by 1, 3
order by 2 desc
limit 100
