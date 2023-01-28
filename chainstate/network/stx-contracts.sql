select date_bin('7 days', block_time, '2021-01-03')::date as block_time
, count(*)
from smart_contracts
join blocks using (block_height)
where block_height > 1
group by 1
order by 1
