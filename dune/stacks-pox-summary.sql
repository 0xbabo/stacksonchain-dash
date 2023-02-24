SELECT count(distinct tx.id) as txs
, round(sum(tx.fee) + sum(tx.output[1].value) + sum(op_pox.value) + sum(op_burn.value), 8) as total_amount
, round(sum(op_pox.value), 8) as pox_amount
, round(sum(op_burn.value), 8) as burn_amount
, round(sum(tx.fee), 8) as fee_amount
, round(sum(tx.output[1].value), 8) as script_amount
FROM bitcoin.transactions tx
LEFT JOIN bitcoin.outputs op_burn ON (op_burn.tx_id = tx.id and op_burn.index > 0
    and op_burn.address = '1111111111111111111114oLvT2')
LEFT JOIN bitcoin.outputs op_pox ON (op_pox.tx_id = tx.id and op_pox.index > 0
    and op_pox.address <> '1111111111111111111114oLvT2' and op_pox.address <> tx.input[1].script_pub_key.address)
WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
AND tx.output_count > 2
AND starts_with(tx.output[1].script_pub_key.hex, '0x6a4c5058325b') -- OP_RETURN + OP_PUSHDATA1(0x50) + magic 'X2' + stx_op '['
