select contract_call_contract_id as "Explorer"
, CASE WHEN EXISTS (select 1 from NFT_EVENTS where split_part(asset_identifier,'::',1) = contract_call_contract_id)
    THEN '<a href="https://gamma.io/collections/' || contract_call_contract_id || '">Gamma</a>'
    END as "Market"
, split_part(contract_call_contract_id,'.',2) as contract_id
, count(distinct sender_address) as users
, count(*) as txs
from transactions tx
where contract_call_contract_id like ANY(ARRAY
['SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.%'
,'SPMWNPDCQMCXANG6BYK2TJKXA09BTSTES0VVBXVR.%'
,'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bitcoin-monkeys%'
,'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-kids-nft'
,'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.slime-components-and-minions'
,'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.monkey-coin'
,'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.world-cup-monkeys'
])
group by contract_call_contract_id
order by users desc, txs desc
limit 100
