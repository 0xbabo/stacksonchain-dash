with const as (
select 1e4 as max_rate
)

select date_bin('30 min', block_time, '2021-01-03') as block_time
-- , max(fee_rate/length(raw_tx)) as "max"
, LEAST(PERCENTILE_CONT(0.90) within group (order by fee_rate/length(raw_tx)),max_rate) as "p90"
, avg(fee_rate/length(raw_tx)) as "mean"
, LEAST(PERCENTILE_CONT(0.50) within group (order by fee_rate/length(raw_tx)),max_rate) as "median"
, LEAST(PERCENTILE_CONT(0.10) within group (order by fee_rate/length(raw_tx)),max_rate) as "p10"
, min(fee_rate/length(raw_tx)) as "min"
from txs
cross join const
where block_time > now() - interval '7 days'
and fee_rate > 0
group by 1, max_rate
order by 1
