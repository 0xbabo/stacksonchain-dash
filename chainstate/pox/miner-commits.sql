with anchor as (
select (data ->> 'block_height')::int as burn_block_height
-- , (data #>> '{inputs,0,prev_out,addr}') as sender_address
-- , (data ->> 'fee')::numeric as fee_amount
-- , (data #>> '{out,0,value}')::numeric as script_amount
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
-- , count(*) as slots
from burnchain_rewards
group by 1
)

-- TODO: Clarify validity. No data for burnchain rewards during burn phase.

select burn_block_height - (burn_block_height - 668050) % 300 as burn_block_height
, avg(r.commit_amount) as net_commit
, avg(a.commit_amount) as anchor_commit
-- , avg(a.fee_amount) as anchor_fee
from blocks bx
join anchor a using (burn_block_height)
join rewards r using (burn_block_height)
group by 1
order by 1
