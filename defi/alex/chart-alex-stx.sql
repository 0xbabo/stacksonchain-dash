with contracts (swap_like,token_x,token_y,functions_like) as (VALUES
('SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%'
,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx::wstx' -- 8D
,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex' -- 8D
, array['%swap%']
))

, weighted as (
select b.block_height, b.block_time
, (balance_x / balance_y :: numeric) as price
, sum(amount)/1e8 as volume -- double counting in some instances
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
    and sender_address = any(array[fx.sender,fx.recipient])
)
where 0 < balance_y
group by 1,2,3
order by 1
)

select to_char( date_bin(
    CASE WHEN block_time > now() - interval '7 days' THEN interval '1 hours' ELSE interval '24 hours' END
    , block_time, '2021-01-03')
    , 'YYYY-MM-DD"T"HH24"h"') as interval
, max(wp.price) as price_max
, min(wp.price) as price_min
, avg(wp.price) as price_avg
, LEAST(0.0 + sum(volume) / 5e7, 2.0) as lerp_vol
, 0 as zero
, log( avg(price) ) * 1.0 + 1.5 as lerp_log
from weighted wp
group by 1
order by 1
