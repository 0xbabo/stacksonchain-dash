with const as ( select
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw' as the_asset
)

, events as (
    select ft.sender, ft.recipient
    , ft.amount / 1e6 as amount
    from ft_events ft
    cross join const
    where asset_identifier = the_asset
)

, credit as (
    select recipient as address
    , sum(amount) as amount
    from events
    group by 1
)

, debit as (
    select sender as address
    , sum(amount) as amount
    from events
    group by 1
)

select address
, credit.amount - coalesce(debit.amount,0) as balance
from credit
left join debit using (address)
where address is not null
order by balance desc nulls last
limit 30
