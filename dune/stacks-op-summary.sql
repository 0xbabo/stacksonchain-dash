SELECT substr(tx.output[1].script_pub_key.hex,5,1) as stx_op_hex
, from_utf8(substr(tx.output[1].script_pub_key.hex,5,1)) as stx_op_ascii
, count(*) as txs
, count(distinct tx.input[1].script_pub_key.address) as accounts
FROM bitcoin.transactions tx
WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
AND tx.output_count > 1
AND substr(tx.output[1].script_pub_key.hex,1,1) = 0x6a -- OP_RETURN, then payload_size
AND substr(tx.output[1].script_pub_key.hex,3,2) = 0x5832 -- STX magic 'X2'
AND substr(tx.output[1].script_pub_key.hex,5,1) IN (0x5e,0x70,0x78,0x24)
GROUP BY 1,2
-- HAVING count(*) > 1
ORDER BY 3 DESC, 4 DESC
