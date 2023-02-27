SELECT from_hex(substr(tx.output[1].script_pub_key.hex,11,2)) as stx_op_hex
, from_utf8(from_hex(substr(tx.output[1].script_pub_key.hex,11,2))) as stx_op_ascii
, count(*) as txs
, count(distinct tx.input[1].script_pub_key.address) as accounts
FROM bitcoin.transactions tx
WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
AND tx.output_count > 1
AND tx.output[1].script_pub_key.hex LIKE '0x6a__5832%' -- OP_RETURN + payload_size + magic 'X2'
AND substr(tx.output[1].script_pub_key.hex,11,2) IN ('5e','70','78','24')
GROUP BY 1,2
-- HAVING count(*) > 1
ORDER BY 3 DESC, 4 DESC
