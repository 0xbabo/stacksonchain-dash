select date_bin('7 days', block_time, '2021-01-03')::date as block_time
, count(distinct sender_address)
from transactions
where block_height > 0
group by 1
