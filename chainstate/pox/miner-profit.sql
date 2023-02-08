with anchor as (
select (data ->> 'block_height')::int as burn_block_height
, (data #>> '{inputs,0,prev_out,addr}') as sender_address
, (data ->> 'fee')::numeric as fee_amount
, (data #>> '{out,0,value}')::numeric as script_amount
-- Sometimes {out,3} does not exist, then typically {out,2,addr} = {inputs,0,prev_out,addr} but not always.
-- Meanwhile {out,0} is always OP_RETURN and thus unspendable.
, (data #>> '{out,1,value}')::numeric
    + CASE WHEN (data #>> '{out,2,addr}') != (data #>> '{inputs,0,prev_out,addr}')
        THEN (data #>> '{out,2,value}')::numeric ELSE 0 END
    as commit_amount
from btc_txs
)

, rewards as (
select burn_block_height
, sum(burn_amount + reward_amount) as commit_amount
, count(*) as slots
from burnchain_rewards
group by 1
)

, daily as (
select btc.ts::date as ts
, avg(stx.open + stx.high + stx.low + stx.close)/4 as stx_avg
, avg(btc.open + btc.high + btc.low + btc.close)/4 as btc_avg
from prices.btc_usd btc
left join prices.stx_usd stx on (stx.ts::date = btc.ts::date)
where btc.timeframe = 'DAY'
and stx.timeframe = 'DAY'
group by 1
)

-- TODO: Clarify validity. No data for burnchain rewards during burn phase.

-- select date_bin('7 days', block_time, '2021-01-03')::date as block_time
select burn_block_height - (burn_block_height - 668050) % 300 as burn_block_height
, avg(mx1.coinbase_amount + mx1.tx_fees_anchored + mx1.tx_fees_streamed_confirmed
    + mx2.tx_fees_streamed_produced)/1e6 * avg(pp.stx_avg/pp.btc_avg)*1e8
    / ( sum(r.commit_amount) / sum(a.commit_amount)) as "Revenue in sats"
, avg(mx1.coinbase_amount + mx1.tx_fees_anchored + mx1.tx_fees_streamed_confirmed
    + mx2.tx_fees_streamed_produced)/1e6 * avg(pp.stx_avg/pp.btc_avg)*1e8
    / ( sum(r.commit_amount) / sum(a.commit_amount) + 1) as "Revenue w/ +1 miner"
, avg(a.commit_amount + a.fee_amount + a.script_amount) as "Anchor cost in sats"
, avg(pp.btc_avg / pp.stx_avg) as "STX / BTC"
-- , avg(pp.stx_avg / pp.btc_avg)*1e8 as "sats / STX"
from blocks bx
join anchor a using (burn_block_height)
join rewards r using (burn_block_height)
join miner_rewards mx1 on (mx1.from_index_block_hash = bx.index_block_hash)
join miner_rewards mx2 on (mx2.from_index_block_hash = bx.index_block_hash)
left join daily pp on (ts = block_time::date)
where mx1.canonical and mx1.coinbase_amount > 0
and mx2.canonical and mx2.coinbase_amount = 0
group by 1
order by 1
