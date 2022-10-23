select tx_hash as "Explorer"
, block_time, block_height, id, tx_index, tx_type, raw_result, block_hash, burn_block_time
-- , parent_block_hash
, parent_burn_block_time, type_id, anchor_mode, status, canonical
, post_conditions, nonce, fee_rate, sender_address, origin_hash_mode, event_count
, microblock_canonical, microblock_sequence, microblock_hash, parent_index_block_hash
, smart_contract_contract_id
, CASE WHEN smart_contract_source_code is null THEN null
    WHEN length(smart_contract_source_code) < 500 THEN smart_contract_source_code
    ELSE '(hidden due to size)'
    END as smart_contract_source_code
, encode(coinbase_payload,'escape') as coinbase_payload
, token_transfer_recipient_address, token_transfer_amount, token_transfer_memo
from transactions
where block_height = 1
-- where id < 10
order by id
limit 100
