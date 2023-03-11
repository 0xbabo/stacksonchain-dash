SELECT concat('<a href="https://mempool.space/tx/'
    , to_hex(tx.id), '" target = "_blank">'
    , substr(to_hex(tx.id),1,16), '...'
    , '</a>') as tx_id
, tx.block_height
, tx.index
, tx.virtual_size as vbytes
, round(tx.fee * 1e8 / tx.virtual_size, 1) as sats_vbyte
, tx.output_count
, concat('<a href="https://mempool.space/address/'
    , tx.input[1].script_pub_key.address, '" target = "_blank">'
    , tx.input[1].script_pub_key.address
    , '</a>') as input_address
, round(tx.fee * 1e8) as fee_amount
, round(tx.output[1].value * 1e8) as script_amount
, length(tx.output[1].script_pub_key.hex) as script_bytes
-- , substr(tx.output[1].script_pub_key.hex,5,1) as stx_op
-- , to_hex(tx.output[1].script_pub_key.hex) as script_hex
, to_hex(substr(tx.output[1].script_pub_key.hex,3+3,20)) as msg_consensus_hash
, to_hex(substr(tx.output[1].script_pub_key.hex,3+23,32)) as msg_vrf_key
, to_hex(substr(tx.output[1].script_pub_key.hex,3+55,25)) as msg_memo
FROM bitcoin.transactions tx
WHERE tx.block_height >= 666050 -- block height of Stacks 2.0 genesis
AND tx.output_count > 1
AND substr(tx.output[1].script_pub_key.hex,1,1) = 0x6a -- OP_RETURN, then payload_size
AND substr(tx.output[1].script_pub_key.hex,3,2) = 0x5832 -- STX magic 'X2'
AND substr(tx.output[1].script_pub_key.hex,5,1) = 0x5e -- PoX VRF key registration
ORDER BY 2 DESC, 3 DESC
-- LIMIT 1000
