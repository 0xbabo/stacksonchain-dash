select date_bin('7 days', block_time, '2021-01-03')::date as block_time
, sum(amount)/1e6 as burned
from stx_events
join blocks using (block_height)
-- where asset_event_type = 'burn'
where asset_event_type_id = 3
group by 1
order by 1
