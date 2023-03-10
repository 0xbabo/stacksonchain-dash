SELECT count(distinct tx.id) as commit_txs
, count(distinct tx.input[1].script_pub_key.address) as commit_accounts
, round(sum(tx.fee) + sum(tx.output_value - coalesce(op_self.value,0)), 8) as total_amount
, round(sum(tx.output_value - coalesce(op_self.value,0)) - sum(coalesce(op_burn.value,0)) - sum(tx.output[1].value), 8) as pox_amount
, round(sum(coalesce(op_burn.value,0)), 8) as burn_amount
, round(sum(tx.fee), 8) as fee_amount
, round(sum(tx.output[1].value), 8) as script_amount
FROM bitcoin.transactions tx
LEFT JOIN LATERAL (
    SELECT sum(op.value) as value FROM bitcoin.outputs op
    WHERE op.tx_id = tx.id AND op.address = '1111111111111111111114oLvT2'
) op_burn ON TRUE
LEFT JOIN LATERAL (
    SELECT sum(op.value) as value FROM bitcoin.outputs op
    WHERE op.tx_id = tx.id AND op.address = tx.input[1].script_pub_key.address
) op_self ON TRUE
WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
AND tx.output_count > 2
AND starts_with(tx.output[1].script_pub_key.hex, 0x6a4c5058325b) -- OP_RETURN + OP_PUSHDATA1(0x50) + magic 'X2' + stx_op '['
