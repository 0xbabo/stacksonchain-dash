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

select date_bin('7 days', block_time, '2021-01-03')::date as interval
, count(*) filter (where namespace = 'btc') as "btc"
, count(*) filter (where namespace = 'stx') as "stx"
, count(*) filter (where namespace = 'app') as "app"
, count(*) filter (where namespace = 'id') as "id"
, count(*) filter (where namespace not in ('btc','stx','app','id')) as "OTHER"
from registry
group by 1
order by 1
