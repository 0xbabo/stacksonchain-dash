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
, to_char(yr.value_stx, '999G999G999G999G999') as "E(val_stx), year"
, to_char(mo.value_stx, '999G999G999G999G999') as "E(val_stx), eoy"
, to_char((yr.value_stx / lag(yr.value_stx) over (order by yr.ts) - 1) * 100, '999G999G999D9') as "ΔE(val_stx), yr/yr (%)"
, to_char((mo.value_stx / yr.value_stx - 1) * 100, '999G999G999D99') "ΔE(val_stx), eoy/yr (%)"
, to_char(yr.value_usd, '999G999G999G999G999') as "E(val_usd), year"
, to_char(mo.value_usd, '999G999G999G999G999') as "E(val_usd), eoy"
, to_char((yr.value_usd / lag(yr.value_usd) over (order by yr.ts) - 1) * 100, '999G999G999D9') as "ΔE(val_usd), yr/yr (%)"
, to_char((mo.value_usd / yr.value_usd - 1) * 100, '999G999G999D9') "ΔE(val_usd), eoy/yr (%)"
from annual yr
left join monthly mo on (date_trunc('year',mo.ts) = yr.ts)
where extract('month' from mo.ts) = 12
order by 1
