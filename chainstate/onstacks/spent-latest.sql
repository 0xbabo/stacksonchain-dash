with const as (
select get_max_block() - 100 as min_block
)

, anchor as (
select (data ->> 'block_height')::int as burn_block_height
, (data #>> '{inputs,0,prev_out,addr}') as sender_address
, (data ->> 'fee')::numeric as fee_amount
-- Sometimes {out,3} does not exist, then typically {out,2,addr} = {inputs,0,prev_out,addr} but not always.
-- Meanwhile {out,0} is always OP_RETURN and thus unspendable.
, (data #>> '{out,1,value}')::numeric
    + CASE WHEN (data #>> '{out,2,addr}') != (data #>> '{inputs,0,prev_out,addr}')
        THEN (data #>> '{out,2,value}')::numeric ELSE 0 END
    as commit_amount
, (data #>> '{out,0,value}')::numeric as script_amount
from btc_txs
)

, avg_anchor as (
select avg(commit_amount + fee_amount + script_amount) as amount
, count(distinct sender_address) as miners_uniq
from anchor
join blocks using (burn_block_height)
cross join const
where block_height > min_block
)

, rewards as (
select burn_block_height
, sum(burn_amount + reward_amount) as commit_amount
, count(*) as slots
from burnchain_rewards
join blocks using (burn_block_height)
cross join const
where block_height > min_block
group by 1
)

, effective as (
select sum(r.commit_amount) / sum(a.commit_amount) as miners
, sum(r.commit_amount) as commit
from rewards r
join anchor a using (burn_block_height)
join blocks using (burn_block_height)
cross join const
where block_height > min_block
)

select eff.commit as "Net commit (sats)"
, (select amount from avg_anchor) as "Avg anchor (sats)"
, (select miners_uniq from avg_anchor) as "Miners (distinct)"
, eff.miners as "Miners (average)"
from effective eff
