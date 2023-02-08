with const as (
select 0 as min_burn_block
)

, anchor as (
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

, anchor_aggregate as (
select sum(commit_amount) as commit_amount
, sum(fee_amount) as fee_amount
, sum(script_amount) as script_amount
, count(distinct sender_address) as miners_uniq
from anchor
cross join const
where burn_block_height > min_burn_block
)

, rewards as (
select burn_block_height
, sum(burn_amount + reward_amount) as commit_amount
-- , count(*) as slots
from burnchain_rewards
cross join const
where burn_block_height > min_burn_block
group by 1
)

, effective as (
select sum(r.commit_amount) / sum(a.commit_amount) as miners_avg
from rewards r
join anchor a using (burn_block_height)
cross join const
where burn_block_height > min_burn_block
)

-- TODO: Clarify validity. No data for burnchain rewards during burn phase.

select (agg.commit_amount + agg.fee_amount + agg.script_amount)/1e8 as "Anchor total (BTC)"
, agg.fee_amount/1e8 as "Anchor fees (BTC)"
, agg.miners_uniq as "Miners (distinct)"
, round(eff.miners_avg,2) as "Miners (average)"
-- , (agg.commit_amount + agg.fee_amount + agg.script_amount)/1e8 * eff.miners_avg as "Est. total spent (BTC)"
-- , (agg.fee_amount)/1e8 * eff.miners_avg as "Est. total fees (BTC)"
from anchor_aggregate agg
cross join effective eff
