with const as (
select '2023-01-01'::timestamp as ts_end
, '2021-01-03'::timestamp as ts_begin
)

, daily_price as (
select btc.ts::date as ts
, avg(stx.open + stx.high + stx.low + stx.close)/4 as stx_avg
, avg(btc.open + btc.high + btc.low + btc.close)/4 as btc_avg
from prices.btc_usd btc
left join prices.stx_usd stx on (stx.ts::date = btc.ts::date)
where stx.timeframe = 'DAY' and btc.timeframe = 'DAY'
group by 1
order by 1
)

, daily as (
select block_time::date as ts
, sum(amount)/1e6 as value
from stx_events
join blocks using (block_height)
cross join const
where block_height > 1
and block_time >= ts_begin
and block_time < ts_end
group by 1
order by 1
)

, daily_running as (
select ts
, avg(value) over (order by ts rows between 6 preceding and current row) as value
from daily d
order by 1
)

select date_bin('2 days', d.ts, '2021-01-03')::date as ts
, avg(d.value) as "Amount (STX)"
, avg(d.value * p.stx_avg) as "Amount (USD value)"
, avg(d.value * p.stx_avg / p.btc_avg) * 1e4 as "Amount (BTC value x1e4)"
, GREATEST(0, 3e7 * ( -4.5 + log(avg(d.value)) )) as "Lerp Log Fees (STX)"
, GREATEST(0, 3e7 * ( -4.5 + log(avg(d.value * p.stx_avg)) )) as "Lerp Log Fees (USD value)"
, GREATEST(0, 3e7 * ( -4.5 + log(avg(d.value * p.stx_avg / p.btc_avg) * 1e4) )) as "Lerp Log Fees (BTC value x1e4)"
from daily_running d
left join daily_price p using (ts)
group by 1
order by 1
