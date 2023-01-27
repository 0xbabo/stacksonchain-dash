with const as (
select '2023-01-01'::timestamp as ts_end
, '2021-01-03'::timestamp as ts_begin
)

, daily as (
select block_time::date as ts
, sum(fee_rate)/1e6 as value
from transactions
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
)

select date_bin('2 days', d.ts, '2021-01-03')::date as ts
, avg(d.value) as "Fees (STX)"
, avg(d.value * (stx.open + stx.high + stx.low + stx.close)/4) as "Fees (USD value)"
, avg(d.value * (stx.open + stx.high + stx.low + stx.close)/4
    * 4/(btc.open + btc.high + btc.low + btc.close)) * 1e4 as "Fees (BTC value x1e4)"
from daily_running d
left join prices.stx_usd stx on (stx.ts::date = d.ts)
left join prices.btc_usd btc on (btc.ts::date = d.ts)
where stx.timeframe = 'DAY' and btc.timeframe = 'DAY'
group by 1
order by 1
