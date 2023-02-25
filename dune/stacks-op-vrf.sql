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
, round(tx.fee * 1e8) as fee_amount
, round(tx.output[1].value * 1e8) as script_amount
, length(from_hex(substr(tx.output[1].script_pub_key.hex,3))) as script_bytes
-- , from_hex(substr(tx.output[1].script_pub_key.hex,11,2)) as stx_op
-- , substr(tx.output[1].script_pub_key.hex,3) as script_hex
, substr(tx.output[1].script_pub_key.hex,7+2*3,2*20) as msg_consensus_hash
, substr(tx.output[1].script_pub_key.hex,7+2*23,2*32) as msg_vrf_key
, substr(tx.output[1].script_pub_key.hex,7+2*55,2*25) as msg_memo
FROM bitcoin.transactions tx
WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
AND tx.output_count > 1
AND tx.output[1].script_pub_key.hex LIKE '0x6a__58325e%' -- OP_RETURN + payload_size + magic 'X2' + stx_op '^'
ORDER BY 2 DESC, 3 DESC
LIMIT 1000
