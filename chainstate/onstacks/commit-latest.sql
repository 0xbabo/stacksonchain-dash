with anchor as (
select (data ->> 'block_height')::int as burn_block_height
, (data ->> 'fee')::numeric as fee
-- Sometimes {out,3} does not exist, then typically {out,2,addr} = {inputs,0,prev_out,addr} but not always.
-- Meanwhile {out,0} is always OP_RETURN and thus unspendable.
, (data #>> '{out,1,value}')::numeric
    + CASE WHEN (data #>> '{out,2,addr}') != (data #>> '{inputs,0,prev_out,addr}')
        THEN (data #>> '{out,2,value}')::numeric ELSE 0 END
    as amount
from btc_txs
)

select block_height
, anc.amount as anchor_commit
, sum(burn_amount + reward_amount) as net_commit
-- , count(*) as reward_slots
from blocks bx
left join anchor anc using (burn_block_height)
left join burnchain_rewards using (burn_block_height)
where block_height > get_max_block() - 100
group by 1,2
order by 1 desc
limit 500
