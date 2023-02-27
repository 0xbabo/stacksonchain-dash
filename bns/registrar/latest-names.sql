select tx_hash as "Explorer"
, tx.block_time::date
, tx.block_height
, tx.fee_rate/1e6 as tx_fee
, left(sender_address,5)||'...'||right(sender_address,5) as minter
, name||'.'||namespace as fqn
, CASE WHEN name ^@ 'xn--' THEN public.idn_punycode_decode(right(name,-4))||'.'||namespace END as depuny
from transactions tx
join lateral (
    select encode(decode(rtrim(split_part(split_part(value,',',1),'0x',2) ,'}'), 'hex'), 'escape') as name
    , encode(decode(rtrim(split_part(split_part(value,',',2),'0x',2) ,'}'), 'hex'), 'escape') as namespace
    from nft_events nx where nx.tx_id = tx.tx_id
    and nx.asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
    -- and nx.asset_event_type = 'mint'
    and nx.asset_event_type_id = 2
) mint ON TRUE
-- and status=1
order by block_height desc, sender_address, namespace
limit 100
