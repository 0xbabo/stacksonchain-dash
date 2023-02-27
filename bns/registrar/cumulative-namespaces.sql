with registry as (
    select block_height, block_time
    , encode(decode(rtrim(split_part(split_part(value,',',1),'0x',2) ,'}'), 'hex'), 'escape') as name
    , encode(decode(rtrim(split_part(split_part(value,',',2),'0x',2) ,'}'), 'hex'), 'escape') as namespace
    from nft_events mint
    join blocks tx using (block_height)
    where asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
    and asset_event_type = 'mint'
    order by block_height desc
)

, series as (
select date_bin('7 days', block_time, '2021-01-03')::date as interval
, namespace
, count(*)
from registry
group by 1,2
order by 1,2
)

select distinct interval
, coalesce(sum(count) filter (where namespace = 'btc') over (order by interval), 0) as btc
, coalesce(sum(count) filter (where namespace = 'stx') over (order by interval), 0) as stx
, coalesce(sum(count) filter (where namespace = 'app') over (order by interval), 0) as app
, coalesce(sum(count) filter (where namespace = 'id') over (order by interval), 0) as id
, coalesce(
    sum(count) filter (where namespace not in ('btc','stx','app','id')) over (order by interval)
    , 0) as "Other"
from series
order by 1
