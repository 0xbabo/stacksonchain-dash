SELECT DISTINCT concat('<a href="https://mempool.space/tx/'
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
, round(1e8 * coalesce(sum(op_other.value) over (partition by tx.id),0)) as other_amount
, round(1e8 * coalesce(sum(op_burn.value) over (partition by tx.id),0)) as burn_amount
, round(tx.fee * 1e8) as fee_amount
, round(tx.output[1].value * 1e8) as script_amount
, length(from_hex(substr(tx.output[1].script_pub_key.hex,3))) as script_size
-- , from_hex(substr(tx.output[1].script_pub_key.hex,11,2)) as stx_op
, substr(tx.output[1].script_pub_key.hex,3) as script_hex
FROM bitcoin.transactions tx
LEFT JOIN bitcoin.outputs op_burn ON (op_burn.tx_id = tx.id and op_burn.index > 0
    and op_burn.address = '1111111111111111111114oLvT2')
LEFT JOIN bitcoin.outputs op_other ON (op_other.tx_id = tx.id and op_other.index > 0
    and op_other.address <> '1111111111111111111114oLvT2' and op_other.address <> tx.input[1].script_pub_key.address)
WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
AND tx.output_count > 1
AND tx.output[1].script_pub_key.hex LIKE '0x6a4c__5832%' -- OP_RETURN + OP_PUSHDATA1(__) + magic 'X2'
AND tx.output[1].script_pub_key.hex NOT LIKE '0x6a4c5058325b%' -- PoX leader block commit
ORDER BY 2 DESC, 3 DESC
LIMIT 1000
