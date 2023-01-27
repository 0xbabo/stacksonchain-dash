-- select bf.block_height - (bf.block_height-1) % 500 as block_height
select bf.burn_block_height - (bf.burn_block_height - 668050) % 300 as burn_block_height
, avg(mx.tx_fees_anchored + mx.tx_fees_streamed_confirmed + mxf.tx_fees_streamed_produced)/1e6 as "avg fees (STX)"
-- coinbase rewards can be slashed in case of (frequent?) empty blocks (citation?)
, min(mx.coinbase_amount/1e6) as "min coinbase (STX)"
-- coinbase rewards accumulate for "missed sortitions"
-- https://docs.stacks.co/docs/understand-stacks/technical-specs#proof-of-transfer-mining
, avg(mx.coinbase_amount/1e6 / (bf.burn_block_height - bfp.burn_block_height)) as "avg coinbase/burnblock (STX)"
, max(mx.coinbase_amount/1e6 / (bf.burn_block_height - bfp.burn_block_height)) as "max coinbase/burnblock (STX)"
, avg(mx.coinbase_amount/1e6) as "avg coinbase (STX)"
-- https://forum.stacks.org/t/pox-consensus-and-stx-future-supply/11232
-- , avg(CASE WHEN b1.burn_block_height <= 676052 THEN 2466
--         WHEN b1.burn_block_height < 840000 THEN 1000
--         ELSE 500 END) as "std coinbase (STX)"
from miner_rewards mx
join miner_rewards mxf using (mature_block_height)
join blocks bm on (bm.index_block_hash = mx.index_block_hash) -- mature block
join blocks bf on (bf.index_block_hash = mx.from_index_block_hash) -- mined block
join blocks bfp on (bfp.block_height = bf.block_height-1) -- mined block parent
where mx.canonical and mx.coinbase_amount > 0
and mxf.canonical and mxf.coinbase_amount = 0
group by 1
order by 1
