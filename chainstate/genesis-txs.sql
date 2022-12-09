select tx_hash as "Explorer"
, b.block_time, burn_block_height, block_height, tx_index, tx_type, type_id
, encode(coinbase_payload,'escape') as coinbase_payload
, CASE WHEN length(smart_contract_source_code) > 200 THEN '(hidden due to size)'
    ELSE smart_contract_source_code
    END as smart_contract_source_code
, smart_contract_contract_id
, token_transfer_memo, token_transfer_recipient_address, token_transfer_amount
, sender_address, nonce, fee_rate
, anchor_mode, status, post_conditions
, origin_hash_mode, event_count
, raw_result, block_hash, burn_block_hash
, parent_index_block_hash, parent_block_hash, parent_burn_block_time
, microblock_sequence, microblock_hash, microblock_canonical, canonical
from transactions tx
join blocks b using (block_height,block_hash,burn_block_time,parent_block_hash,parent_index_block_hash)
where block_height = 1
order by tx_index
limit 100
