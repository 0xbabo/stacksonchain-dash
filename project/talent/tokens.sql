with tokens (contract_id) as (
VALUES ('SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token::vibes-token') -- hire vibes
, ('SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4ktqebauw9::tokensoft-token') -- zero
)

, props as (
select contract_id as asset_identifier
, (properties ->> 'name') name
, (properties ->> 'symbol') symbol
, (properties ->> 'decimals') :: numeric decimals
, power(10, (properties ->> 'decimals') :: numeric) base
from token_properties
join tokens using (contract_id)
)

, supply as (
with credit as (
select fx.asset_identifier, recipient as address
, sum(amount) as amount
from props tk
join ft_events fx using (asset_identifier)
group by 1,2
)
, balance as (
select cr.asset_identifier, cr.address
, cr.amount - coalesce(debit.amount,0) as amount
from credit cr
left join lateral (
    select sum(fx.amount) as amount from ft_events fx
    where fx.asset_identifier = cr.asset_identifier
    and fx.sender = cr.address
) debit ON TRUE
)
select asset_identifier
, count(*) as users
, count(*) filter (where amount > 0) as holders
, sum(amount) as supply
from balance
join props using (asset_identifier)
where address is not null
group by 1
)

select split_part(asset_identifier,'::',1) as "Explorer"
, name, symbol, decimals
, users, holders
, CASE WHEN base is null THEN supply::varchar
    ELSE to_char( supply / base, 'fm999G999G999G999G999G999D999')
    END as "Circulating Supply"
-- , block_height as genesis
from props
join supply using (asset_identifier)
-- join smart_contracts on (contract_id = split_part(asset_identifier,'::',1))
order by users desc nulls last
