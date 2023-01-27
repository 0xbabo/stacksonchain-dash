-- with daily as (
-- select btc.ts::date as ts
-- , avg(stx.open + stx.high + stx.low + stx.close)/4 as stx_avg
-- , avg(btc.open + btc.high + btc.low + btc.close)/4 as btc_avg
-- from prices.btc_usd btc
-- left join prices.stx_usd stx on (stx.ts::date = btc.ts::date)
-- where btc.timeframe = 'DAY'
-- and stx.timeframe = 'DAY'
-- group by 1
-- )

-- select burn_block_height - (burn_block_height - 668050) % 300
-- select burn_block_height - (burn_block_height - 668050) % 2100
select 1 + (burn_block_height - 668050) / 2100 as cycle
, sum(reward_amount)/1e8 as "Rewards (BTC)"
-- , sum(reward_amount)/1e8 * 1e4 as "Rewards (BTC x1e4)"
-- , sum(reward_amount)/1e8 * avg(pp.btc_avg) as "Rewards (USD value)"
-- , sum(reward_amount)/1e8 * avg(pp.btc_avg) / avg(pp.stx_avg) as "Rewards (STX value)"
from burnchain_rewards
join blocks bk using (burn_block_height)
-- left join daily pp on (pp.ts = block_time::date)
where burn_block_height >= 668050
group by 1
order by 1
limit 500
