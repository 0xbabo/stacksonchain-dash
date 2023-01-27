with anchor as (
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

, rewards as (
select burn_block_height
, sum(burn_amount + reward_amount) as commit_amount
, count(*) as slots
from burnchain_rewards
group by 1
)

select burn_block_height - (burn_block_height - 668050) % 300 as burn_block_height
, sum(r.commit_amount) / sum(a.commit_amount) as "miners (average)"
, count(distinct a.sender_address) as "miners (distinct)"
from blocks bx
join anchor a using (burn_block_height)
join rewards r using (burn_block_height)
group by 1
order by 1
