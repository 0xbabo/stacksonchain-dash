select date_bin('30 min', block_time, to_timestamp(0)) as block_time,
    LEAST(GREATEST(0.001,PERCENTILE_CONT(0.90) within group (order by fee_rate/1e6*180/length(raw_tx))),1) as "90 pctl (High)",
    avg(fee_rate/1e6*180/length(raw_tx)) as "Mean",
    LEAST(GREATEST(0.001,PERCENTILE_CONT(0.50) within group (order by fee_rate/1e6*180/length(raw_tx))),1) as "50 pctl (Standard)",
    LEAST(GREATEST(0.001,PERCENTILE_CONT(0.10) within group (order by fee_rate/1e6*180/length(raw_tx))),1) as "10 pctl (Low)"
from txs
where block_time > now() - interval '7 days'
and fee_rate > 0
-- and status = 1
group by 1
order by 1
