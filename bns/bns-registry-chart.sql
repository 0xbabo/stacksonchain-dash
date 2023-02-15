with registry as (
    select block_height, block_time
    , encode(decode(rtrim(split_part(split_part(value,',',1),'0x',2) ,'}'), 'hex'), 'escape') as name
    , encode(decode(rtrim(split_part(split_part(value,',',2),'0x',2) ,'}'), 'hex'), 'escape') as namespace
    from nft_events mint
    join blocks tx using (block_height)
    where asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
    -- and asset_event_type = 'mint'
    and asset_event_type_id = 2
    order by block_height desc
)

select date_bin('7 days', block_time, '2021-01-03')::date as interval
, count(*) filter (where name ~ '^[0-9]+$' and length(name)<3) as "1-2 digits"
, count(*) filter (where name ~ '^[0-9]+$' and length(name)=3) as "3 digits"
, count(*) filter (where name ~ '^[0-9]+$' and length(name)=4) as "4 digits"
, count(*) filter (where name ~ '^[0-9]+$' and length(name)>=5) as "5+ digits"
, count(*) filter (where name ~ '^[a-z]+$' and length(name)<3) as "1-2 letters"
, count(*) filter (where name ~ '^[a-z]+$' and length(name)=3) as "3 letters"
, count(*) filter (where name ~ '^[a-z]+$' and length(name)=4) as "4 letters"
, count(*) filter (where name ~ '^[a-z]+$' and length(name)>=5) as "5+ letters"
, count(*) filter (where name ^@ 'xn--') as "punycode"
from registry
where namespace = 'btc'
group by 1
order by 1
