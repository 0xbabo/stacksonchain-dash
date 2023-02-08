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

, monthly as (
select date_trunc('month', ts)::date as ts
, avg(d.value) as value_stx
, avg(d.value * p.stx_avg) as value_usd
, avg(d.value * p.stx_avg / p.btc_avg) as value_btc
from daily d
left join daily_price p using (ts)
group by 1
)

, annual as (
select date_trunc('year', ts)::date as ts
, avg(d.value) as value_stx
, avg(d.value * p.stx_avg) as value_usd
, avg(d.value * p.stx_avg / p.btc_avg) as value_btc
from daily d
left join daily_price p using (ts)
group by 1
)

select extract('year' from mo.ts) as year
, round(yr.value_btc, 4)::text as "value(BTC), year"
, round(mo.value_btc, 4)::text as "value(BTC), eoy"
, round((mo.value_btc / yr.value_btc - 1) * 100, 1)::text "Δvalue(BTC), eoy/yr (%)"
, round((yr.value_btc / lag(yr.value_btc) over (order by yr.ts) - 1) * 100, 1)::text as "Δvalue(BTC), yr/yr (%)"
from annual yr
left join monthly mo on (date_trunc('year',mo.ts) = yr.ts)
where extract('month' from mo.ts) = 12
order by 1
