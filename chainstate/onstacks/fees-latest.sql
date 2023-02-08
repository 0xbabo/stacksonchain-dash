with anchor as (
select (data ->> 'block_height')::int as burn_block_height
, (data ->> 'fee')::numeric as fee_amount
, (data #>> '{out,0,value}')::numeric as script_amount
from btc_txs
)

select block_height
, anc.fee_amount as anchor_fee
, anc.script_amount as anchor_script
from blocks bx
left join anchor anc using (burn_block_height)
where block_height > get_max_block() - 100
order by 1 desc
limit 500
