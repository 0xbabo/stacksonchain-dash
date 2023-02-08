with anchor as (
select (data ->> 'block_height')::int as burn_block_height
-- , (data #>> '{inputs,0,prev_out,addr}') as sender_address
, (data ->> 'fee')::numeric as fee_amount
, (data #>> '{out,0,value}')::numeric as script_amount
from btc_txs
)

select burn_block_height - (burn_block_height - 668050) % 300 as burn_block_height
-- , avg(a.commit_amount) as anchor_commit
, avg(a.fee_amount) as anchor_fee
, avg(a.script_amount) as anchor_script
from blocks bx
join anchor a using (burn_block_height)
group by 1
order by 1
