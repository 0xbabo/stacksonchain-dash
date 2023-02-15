with markets (title,contract_format,function_name) as (VALUES
    ('price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.market','accept_bid'),
    ('Byzantion','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bns-marketplace-%','accept-bid'),
    ('Gamma','%.bns-%-v1', 'purchase-name')
)

select distinct tx.tx_hash as "Explorer"
, title as market
, tx.block_time::date
, CASE WHEN function_name = 'purchase-name'
    THEN left(tx.sender_address,5)||'...'||right(tx.sender_address,5)
    ELSE left(nx.recipient,5)||'...'||right(nx.recipient,5)
    END as buyer_address
, buyer.bns ||'.'|| buyer.namespace as buyer_bns
, sale.bns ||'.'|| sale.namespace as bought_fqn
, CASE WHEN sale.bns ^@ 'xn--' THEN idn_punycode_decode(right(sale.bns,-4)) ||'.'|| sale.namespace END as depunycode
, sum(sx.amount/1e6) over (partition by tx.tx_id) as "Price (STX)"
from nft_events nx
join transactions tx using (tx_id)
join markets on (contract_call_contract_id like contract_format and contract_call_function_name = function_name)
join stx_events sx using (tx_id)
join stxop.bns_address sale on (
    namespace = encode(decode(rtrim(split_part(split_part(nx.value,',',2),'0x',2) ,'}'), 'hex'), 'escape')
    and bns = encode(decode(rtrim(split_part(split_part(nx.value,',',1),'0x',2) ,'}'), 'hex'), 'escape')
)
left join stxop.bns_address buyer on (
    buyer.address = CASE WHEN function_name = 'purchase-name' THEN tx.sender_address ELSE nx.recipient END
)
where nx.asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
and nx.asset_event_type = 'transfer'
and (sale.bns ~ '^0x[0-9a-f]+$'
    or (sale.bns ^@ 'xn--'
    -- using the decoded value in the decoder function call is much faster here
    and idn_punycode_decode(right(encode(decode(rtrim(split_part(split_part(nx.value,',',1),'0x',2) ,'}'), 'hex'), 'escape'),-4))
    ~ ANY(ARRAY[
    '^[\x4E00\x4E8C\x4E09\x56DB\x4E94\x516D\x4E03\x516B\x4E5D\x96F6\x3007]+$' -- CJK digits
    ,'^[\x660-\x669]+$' -- Arabic digits
    ,'^[\x1F1E6-\x1F1FF]{2}$' -- Flags
    ])
))
-- and sale.namespace in ('btc','stx','id','app')
order by block_time desc
limit 100
