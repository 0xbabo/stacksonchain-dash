with tokens (contract_id) as (
VALUES ('SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4ktqebauw9::tokensoft-token') -- zero authority
, ('SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token::vibes-token') -- hire vibes
-- , ('SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.forcecoin::force') -- jungle force
-- , ('SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken::ROMA') -- punks army
-- , ('SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti::SPAGHETTI') -- spaghetti punks
-- , ('SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega::mega') -- megapont
-- , ('SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.points::points') -- tiles points v1
-- , ('SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.board-points::points') -- tiles points v2
-- , ('SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1.stacks-pops-ice-v2::ice') -- token_ice_v2
-- , ('SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1.stacks-pops-ice-v1::ice') -- token_ice_v1
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
, split_part(split_part(asset_identifier,'::',1),'.',2) as contract_name
-- , name
, symbol, decimals
, users, holders
, CASE WHEN base is null THEN supply::varchar
    ELSE to_char( supply / base, 'fm999G999G999G999G999G999D999')
    END as "Circulating Supply"
-- , block_height as genesis
from props
join supply using (asset_identifier)
-- join smart_contracts on (contract_id = split_part(asset_identifier,'::',1))
order by users desc nulls last, holders desc nulls last
