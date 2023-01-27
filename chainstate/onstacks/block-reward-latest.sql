select mx.recipient
, sum(mx.coinbase_amount)/1e6 as net_reward
from miner_rewards mx
where mx.mature_block_height > get_max_block() - 100
and mx.canonical is true
group by 1
order by 2 desc
limit 100
