select tx.tx_hash as "Explorer"
, tx.block_time::date
, tx.block_height
, left(tx.sender_address,5) ||'...'|| right(tx.sender_address,5) as sender_address
, bns.bns || '.' || bns.namespace as sender_bns
, encode(b(fa.repr),'escape') as namespace
from transactions tx
join function_args fa using (tx_hash)
left join stxop.bns_address bns on (bns.address = tx.sender_address)
where contract_call_contract_id like ANY(ARRAY[
'SP000000000000000000002Q6VF78.bns'
,'SPC0KWNBJ61BDZRPF3W2GHGK3G3GKS8WZ7ND33PS.%'
])
and contract_call_function_name like 'namespace-%'
and fa.name = 'namespace'
order by tx.block_height desc
limit 100
