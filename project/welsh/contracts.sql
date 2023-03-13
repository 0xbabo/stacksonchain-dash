select contract_call_contract_id as "Explorer"
, CASE WHEN EXISTS (select 1 from NFT_EVENTS where split_part(asset_identifier,'::',1) = contract_call_contract_id)
    THEN '<a href="https://gamma.io/collections/' || contract_call_contract_id || '">Gamma</a>'
    END as "Market"
, split_part(contract_call_contract_id,'.',2) as contract_id
, count(distinct sender_address) as users
, count(*) as txs
from transactions tx
where contract_call_contract_id like ANY(ARRAY
['SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token'
,'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.happy-welsh'
])
group by contract_call_contract_id
order by users desc, txs desc
limit 100
