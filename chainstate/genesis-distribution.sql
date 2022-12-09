select pow(10,round(log(10,amount/1e6),1)) as "amount"
, log(10,count(*)) as "log10_count"
from stx_events
where block_height = 1
group by 1
order by 1
