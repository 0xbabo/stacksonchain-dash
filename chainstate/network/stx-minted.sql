-- select tx_hash as "Explorer", block_height
select block_height
, count(distinct recipient) as recipients
, sum(amount)/1e6/1e3 as "Amount (kSTX)"
from stx_events
-- join blocks using (block_height)
-- where asset_event_type = 'mint'
where asset_event_type_id = 2
and block_height > 1
group by 1
order by 1
