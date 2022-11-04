select contract_id as "Explorer"
, block_height
, contract_id
, length(raw_tx) as size
, (position('define-non-fungible-token ' in source_code) > 0) :: text as is_nft
, (position('define-fungible-token ' in source_code) > 0) :: text as is_ft
, (position('define-constant sender ''SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR' in source_code) > 0) :: text as is_boilerplate
from smart_contracts
join txs using (tx_hash, block_height)
where contract_id not like '%.bns-%-v1'
and contract_id not like 'SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM.neoswap-sc-%'
order by block_height desc
limit 100
