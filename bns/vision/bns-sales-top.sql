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
, CASE WHEN buyer.bns ^@ 'xn--' THEN idn_punycode_decode(right(buyer.bns,-4)) ||'.'|| buyer.namespace END as b_puny
, sale.bns ||'.'|| sale.namespace as sold_fqn
, CASE WHEN sale.bns ^@ 'xn--'
    THEN idn_punycode_decode(right(encode(decode(rtrim(split_part(split_part(nx.value,',',1),'0x',2) ,'}'), 'hex'), 'escape'),-4))
        ||'.'|| sale.namespace END as s_puny
, sum(sx.amount/1e6) over (partition by tx_id) as "Price (STX)"
from nft_events nx
join transactions tx using (tx_id)
join markets on (contract_call_contract_id like contract_format and contract_call_function_name = function_name)
join stx_events sx using (tx_id)
join stxop.bns_address sale on (
    namespace = encode(decode(rtrim(split_part(split_part(value,',',2),'0x',2) ,'}'), 'hex'), 'escape')
    and bns = encode(decode(rtrim(split_part(split_part(value,',',1),'0x',2) ,'}'), 'hex'), 'escape')
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
order by "Price (STX)" desc, 3, 1
limit 100
