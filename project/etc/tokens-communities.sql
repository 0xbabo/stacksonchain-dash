with tokens (contract_id) as (
VALUES ('SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token::vibes-token') -- hire vibes
, ('SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4ktqebauw9::tokensoft-token') -- zero
-- TOX (Project Indigo - off chain?)
-- Pogs (The Guests - off chain?)
-- Shrooms (Nonnish - off chain?)
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

, token_flow as (
select account, asset_identifier, sum(delta) as balance from (
    select recipient as account, asset_identifier, sum(amount) as delta
    from ft_events
    join props using (asset_identifier)
    group by 1, 2
union all
    select sender as account, asset_identifier, -sum(amount) as delta
    from ft_events
    join props using (asset_identifier)
    group by 1, 2
) sub
group by 1, 2
)

, token_supply as (
select asset_identifier
, split_part(asset_identifier,'.',2) as contract_name
, sum(balance) as supply
, count(*) as users
from token_flow
where account is not null
group by 1
)

select split_part(contract_id,'::',1) as "Explorer"
, name, symbol, contract_name, decimals
, CASE WHEN base is null THEN supply::varchar
    ELSE to_char( supply / base, 'fm999G999G999G999G999G999D999')
    END as "Circulating Supply"
, users
, block_height as genesis
from props
join token_supply using (asset_identifier)
join smart_contracts on (contract_id = split_part(asset_identifier,'::',1))
order by users desc nulls last
