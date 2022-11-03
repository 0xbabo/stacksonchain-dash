with markets (title,contract_format,function_name) as (VALUES
    ('price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.market','accept_bid'),
    ('Byzantion','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bns-marketplace-%','accept-bid'),
    ('Gamma','%.bns-%-v1', 'purchase-name')
)

, bns_lookup as (
    select distinct on (address) address, bns, namespace
    from stxop.bns_address
)

select CASE WHEN function_name = 'purchase-name'
    THEN left(tx.sender_address,5)||'...'||right(tx.sender_address,5)
    ELSE left(nx.recipient,5)||'...'||right(nx.recipient,5)
    END as buyer
, buyer.bns ||'.'|| buyer.namespace as buyer_bns
, sum(sx.amount/1e6) as "Total Vol (STX)"
, count(distinct tx_id) as purchases
from nft_events nx
join transactions tx using (tx_id)
join markets on (contract_call_contract_id like contract_format and contract_call_function_name = function_name)
join stx_events sx using (tx_id)
join bns_lookup sale on (
    bns = encode(decode(replace(split_part(split_part(nx.value,',',1),'=',2) ,'0x',''), 'hex'), 'escape') and
    namespace = encode(decode(replace(split_part(split_part(nx.value,'=',3),'}',1) ,'0x',''), 'hex'), 'escape')
)
left join bns_lookup buyer on (
    CASE WHEN function_name = 'purchase-name'
    THEN tx.sender_address
    ELSE nx.recipient
    END = buyer.address
)
where nx.asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
and nx.asset_event_type = 'transfer'
and encode(decode(right(split_part(split_part(nx.value,'=',3),'}',1),-2), 'hex'), 'escape') = 'btc'
group by 1,2
order by 3 desc
limit 100
