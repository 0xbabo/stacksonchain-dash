SELECT concat('<a href="https://mempool.space/tx/'
    , to_hex(tx.id), '" target = "_blank">'
    , substr(to_hex(tx.id),1,16), '...'
    , '</a>') as tx_id
, tx.block_height
, tx.index
, tx.virtual_size as vbytes
, tx.output_count
, concat('<a href="https://mempool.space/address/'
    , tx.input[1].script_pub_key.address, '" target = "_blank">'
    , tx.input[1].script_pub_key.address
    , '</a>') as input_address
, round((tx.output_value - tx.output[1].value - coalesce(op_self.value,0) - coalesce(op_burn.value,0)) * 1e8) as pox_amount
, round(coalesce(op_burn.value,0) * 1e8) as burn_amount
, round(tx.fee * 1e8) as fee_amount
, round(tx.output[1].value * 1e8) as script_amount
, concat('<a href="https://explorer.stacks.co/block/0x'
    , to_hex(substr(tx.output[1].script_pub_key.hex,4+3,32)), '" target = "_blank">'
    , substr(to_hex(substr(tx.output[1].script_pub_key.hex,4+3,32)),1,16), '...'
    , '</a>') as msg_block_hash
-- , to_hex(substr(tx.output[1].script_pub_key.hex,4+35,32)) as msg_new_seed
, bytearray_to_integer(substr(tx.output[1].script_pub_key.hex,4+67,4)) as msg_parent_block
, bytearray_to_integer(substr(tx.output[1].script_pub_key.hex,4+71,2)) as msg_parent_txoff
, bytearray_to_integer(substr(tx.output[1].script_pub_key.hex,4+73,4)) as msg_key_block
, bytearray_to_integer(substr(tx.output[1].script_pub_key.hex,4+77,2)) as msg_key_txoff
, bytearray_to_integer(substr(tx.output[1].script_pub_key.hex,4+79,1)) as msg_burn_parent_mod
FROM bitcoin.transactions tx
LEFT JOIN LATERAL (
    SELECT sum(op.value) as value FROM bitcoin.outputs op
    WHERE op.tx_id = tx.id AND op.address = '1111111111111111111114oLvT2'
) op_burn ON TRUE
LEFT JOIN LATERAL (
    SELECT sum(op.value) as value FROM bitcoin.outputs op
    WHERE op.tx_id = tx.id AND op.address = tx.input[1].script_pub_key.address
) op_self ON TRUE
-- WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
WHERE tx.block_height >= 777000 -- more recent
AND tx.output_count > 2
AND starts_with(tx.output[1].script_pub_key.hex, 0x6a4c5058325b) -- OP_RETURN + OP_PUSHDATA1(0x50) + magic 'X2' + stx_op '['
ORDER BY 2 DESC, 3 DESC
LIMIT 1000
