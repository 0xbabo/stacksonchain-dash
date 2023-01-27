with daily as (
select btc.ts::date as ts
, avg(stx.open + stx.high + stx.low + stx.close)/4 as stx_avg
, avg(btc.open + btc.high + btc.low + btc.close)/4 as btc_avg
from prices.btc_usd btc
left join prices.stx_usd stx on (stx.ts::date = btc.ts::date)
where btc.timeframe = 'DAY'
and stx.timeframe = 'DAY'
group by 1
)

select cycle_id
-- select burn_block_height - (burn_block_height - 668050) % 2100 as burn_block_height
, 1e6/stacked * sum(reward_amount)/1e8 * avg(pp.btc_avg / pp.stx_avg) * 25 * 100 as "APR (%)"
from pox_info
join blocks bk on (cycle_id = 1 + (burn_block_height - 668050) / 2100)
left join burnchain_rewards using (burn_block_height)
left join daily pp on (pp.ts = block_time::date)
where burn_block_height >= 668050
and stacked > 0
group by 1, stacked
order by 1
limit 500
