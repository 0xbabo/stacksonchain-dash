SELECT concat('<a href="https://mempool.space/tx/'
    , substr(tx.id,3), '" target = "_blank">'
    , substr(tx.id,3,10), '...'
    , '</a>') as tx_id
, tx.block_height
, tx.index
, tx.size
, tx.output_count
, concat('<a href="https://mempool.space/address/'
    , tx.input[1].script_pub_key.address, '" target = "_blank">'
    , tx.input[1].script_pub_key.address
    , '</a>') as input_address
, round((tx.output_value - tx.output[1].value - coalesce(op_self.value,0) - coalesce(op_burn.value,0)) * 1e8) as pox_amount
, round(coalesce(op_burn.value,0) * 1e8) as burn_amount
, round(tx.fee * 1e8) as fee_amount
, round(tx.output[1].value * 1e8) as script_amount
-- , 'TBD' as canonical
, concat('<a href="https://explorer.stacks.co/block/0x'
    , substr(tx.output[1].script_pub_key.hex,9+2*3,2*32), '" target = "_blank">'
    , substr(tx.output[1].script_pub_key.hex,9+2*3,10), '...'
    , '</a>') as msg_block_hash
-- , substr(tx.output[1].script_pub_key.hex,9+2*35,2*32) as msg_new_seed
, bytearray_to_integer(from_hex(substr(tx.output[1].script_pub_key.hex,9+2*67,2*4))) as msg_parent_block
, bytearray_to_integer(from_hex(substr(tx.output[1].script_pub_key.hex,9+2*71,2*2))) as msg_parent_txoff
, bytearray_to_integer(from_hex(substr(tx.output[1].script_pub_key.hex,9+2*73,2*4))) as msg_key_block
, bytearray_to_integer(from_hex(substr(tx.output[1].script_pub_key.hex,9+2*77,2*2))) as msg_key_txoff
, bytearray_to_integer(from_hex(substr(tx.output[1].script_pub_key.hex,9+2*79,2*1))) as msg_burn_parent_mod
FROM bitcoin.transactions tx
LEFT JOIN LATERAL (
    SELECT op.tx_id as id, sum(op.value) as value FROM bitcoin.outputs op
    WHERE op.address = '1111111111111111111114oLvT2'
    GROUP BY 1
) op_burn ON (op_burn.id = tx.id)
LEFT JOIN LATERAL (
    SELECT op.tx_id as id, sum(op.value) as value FROM bitcoin.outputs op
    WHERE op.address = tx.input[1].script_pub_key.address
    GROUP BY 1
) op_self ON (op_self.id = tx.id)
-- WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
WHERE tx.block_height >= 777000 -- more recent
AND tx.output_count > 2
AND starts_with(tx.output[1].script_pub_key.hex, '0x6a4c5058325b') -- OP_RETURN + OP_PUSHDATA1(0x50) + magic 'X2' + stx_op '['
ORDER BY 2 DESC, 3 DESC
LIMIT 1000