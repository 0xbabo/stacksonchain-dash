select data #>> '{inputs,0,prev_out,addr}' as miner
, count(*) as blocks_anchored
from btc_txs btc
join blocks bx on (burn_block_height = (data ->> 'block_height')::int)
where block_height > get_max_block() - 100
group by 1
order by 2 desc
limit 100
