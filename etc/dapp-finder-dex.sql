select contract_id as "Explorer"
, left(contract_id,5)||'...'||right(split_part(contract_id,'.',1),5) as deployer
, split_part(contract_id,'.',2) as contract_name
, sc.block_height as deploy_blk
, length(source_code) as src_len
, length(abi::varchar) as abi_len
, count(distinct sender_address) as users
, count(distinct tx_id) as txs
from smart_contracts sc
join transactions tx on (contract_call_contract_id = contract_id)
-- where contract_id ilike ANY(ARRAY['%.%pool%'])
-- where contract_id ilike ANY(ARRAY['%.%farm%'])
where sc.contract_id ilike ANY(ARRAY[
 '%.%swap%'
])
and not sc.contract_id like ANY(ARRAY[
 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%' -- LNSwap
,'SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM.%' -- NeoSwap
])
group by 1,2,3,4,5,6
order by txs desc, users desc
limit 100
