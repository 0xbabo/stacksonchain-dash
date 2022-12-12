with markets (title,contract_format,function_name) as (VALUES
    ('price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.market','accept_bid'),
    ('Byzantion','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bns-marketplace-%','accept-bid'),
    ('Gamma','%.bns-%-v1', 'purchase-name')
)

select tx.tx_hash as "Explorer"
-- , contract_call_function_name as function_name
, title as market
, tx.block_time
, CASE WHEN function_name = 'purchase-name'
    THEN left(tx.sender_address,5)||'...'||right(tx.sender_address,5)
    ELSE left(nx.recipient,5)||'...'||right(nx.recipient,5)
    END as buyer_address
, buyer.bns ||'.'|| buyer.namespace as buyer_bns
, sale.bns ||'.'|| sale.namespace as bought_fqn
, sum(sx.amount/1e6) as "Price (STX)"
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
and nx.asset_event_type = 'transfer'
group by 1,2,3,4,5,6
order by "Price (STX)" desc
limit 100
