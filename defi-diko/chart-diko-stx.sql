
with contracts (swap_like,token_x,token_y,functions_like) as (VALUES
('SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap-%'
,'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx'
,'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko'
, array['%swap%']
))

, weighted as (
select b.block_height, b.block_time
, (balance_x / balance_y :: numeric) as price
, sum(amount)/1e6 as volume
from contracts cc
join dex.swap_balances sb on (
    contract_id like swap_like
    and cc.token_x = sb.token_x
    and cc.token_y = sb.token_y
)
join blocks b using (block_height)
left join transactions tx on (
    tx.block_height = b.block_height
    and contract_call_contract_id like swap_like
    and contract_call_function_name like any(functions_like)
)
left join ft_events fx on (
    fx.block_height = b.block_height and fx.tx_id = tx.tx_id
    and fx.asset_identifier = cc.token_y
    -- and tx.sender_address = any(array[fx.sender,fx.recipient])
    and contract_call_contract_id = any(array[fx.sender,fx.recipient])
)
where 0 < balance_y
group by 1,2,3
order by 1
)

select date_bin('1 day', wp.block_time, '2021-10-01') as interval
, max(wp.price) as price_max
, min(wp.price) as price_min
, avg(wp.price) as price_avg
, LEAST(-1.0 + coalesce(sum(volume),0) / 1e6, 1) as lerp_vol
, 0 as zero
, log(avg(price)) * 1.5 + 2.5 as log_rate
from weighted wp
group by 1
order by 1
