with markets (title,contract_format,function_name) as (VALUES
    ('price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.market','accept_bid'),
    ('Byzantion','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bns-marketplace-%','accept-bid'),
    ('Gamma','%.bns-%-v1', 'purchase-name')
)

select tx.tx_hash as "Explorer"
, title as market
, date_trunc('second',age(now(),block_time))::text as "Age (hh:mm:ss)"
, CASE WHEN function_name = 'purchase-name'
    THEN left(tx.sender_address,5)||'...'||right(tx.sender_address,5)
    ELSE left(nx.recipient,5)||'...'||right(nx.recipient,5)
    END as buyer_address
, buyer.bns ||'.'|| buyer.namespace as buyer_bns
, CASE WHEN buyer.bns ^@ 'xn--' THEN idn_punycode_decode(right(buyer.bns,-4)) ||'.'|| buyer.namespace END as buyer_puny
, sale.bns ||'.'|| sale.namespace as sale_fqn
, CASE WHEN sale.bns ^@ 'xn--'
    THEN idn_punycode_decode(right(encode(decode(rtrim(split_part(split_part(nx.value,',',1),'0x',2) ,'}'), 'hex'), 'escape'),-4))
        ||'.'|| sale.namespace END as sale_puny
, stx.value as "Price (STX)"
from transactions tx
join nft_events nx using (tx_id)
left join lateral (
    select sum(amount)/1e6 as value
    from stx_events sx where sx.tx_id = tx.tx_id
) stx on true
join markets on (contract_call_contract_id like contract_format and contract_call_function_name = function_name)
join stxop.bns_address sale on (
    namespace = encode(decode(rtrim(split_part(split_part(nx.value,',',2),'0x',2) ,'}'), 'hex'), 'escape')
    and bns = encode(decode(rtrim(split_part(split_part(nx.value,',',1),'0x',2) ,'}'), 'hex'), 'escape')
)
left join stxop.bns_address buyer on (
    CASE WHEN function_name = 'purchase-name'
    THEN tx.sender_address
    ELSE nx.recipient
    END = buyer.address
)
where nx.asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
-- and nx.asset_event_type = 'transfer'
and nx.asset_event_type_id = 1
and stx.value >= 100
order by tx.id desc
limit 100
