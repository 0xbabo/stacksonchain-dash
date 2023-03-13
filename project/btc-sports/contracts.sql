select contract_call_contract_id as "Explorer"
, CASE WHEN EXISTS (select 1 from NFT_EVENTS where split_part(asset_identifier,'::',1) = contract_call_contract_id)
    THEN '<a href="https://gamma.io/collections/' || contract_call_contract_id || '">Gamma</a>'
    END as "Market"
, split_part(contract_call_contract_id,'.',2) as contract_id
, count(distinct sender_address) as users
, count(*) as txs
from transactions tx
where contract_call_contract_id like ANY(ARRAY
['SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.btc-sports-og-soccer'
,'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.btc-sports-vip-pass'
,'SP2BE8TZATXEVPGZ8HAFZYE5GKZ02X0YDKAN7ZTGW.btc-sports-flags-nft'
])
group by contract_call_contract_id
order by users desc, txs desc
limit 100
