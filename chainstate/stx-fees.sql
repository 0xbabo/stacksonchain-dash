select date_bin('3.5 days', block_time, '2021-01-03')::date as block_time
, sum(fee_rate) / 1e6 as total
from txs
-- where block_time > now() - interval '7 days'
-- and fee_rate > 0
group by 1
order by 1
