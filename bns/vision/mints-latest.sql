with registry as (
select tx.block_height
, tx.block_time
, tx.tx_hash
, tx.sender_address
, fee_rate
, encode(decode(rtrim(split_part(split_part(value,',',1),'0x',2) ,'}'), 'hex'), 'escape') as name
, encode(decode(rtrim(split_part(split_part(value,',',2),'0x',2) ,'}'), 'hex'), 'escape') as namespace
from nft_events mint
join transactions tx using (tx_id)
-- join stxop.bns_address bx using (tx_hash)
where mint.asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
-- and mint.asset_event_type = 'mint'
and mint.asset_event_type_id = 2
-- and status=1
order by block_height desc, sender_address, namespace
limit 500
)

select tx_hash as "Explorer"
, block_height
, block_time::date
, fee_rate/1e6 as tx_fee
, left(sender_address,5)||'...'||right(sender_address,5) as minter
-- , namespace
, name||'.'||namespace as fqn
, CASE WHEN name ^@ 'xn--' THEN public.idn_punycode_decode(right(name,-4))||'.'||namespace END as depunycode
from registry
order by block_height desc, minter, namespace
