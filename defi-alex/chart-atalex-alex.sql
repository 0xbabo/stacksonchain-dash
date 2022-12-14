with contracts (swap_like,token_x,token_y,functions_like) as (VALUES
('SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%'
,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex' -- 8D
,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex' -- 8D
, array['%swap%']
))

, const as (
    select '2022-04-26T00:00:00Z'::timestamp as start_time
)

, weighted as (
select b.block_height, b.block_time
, (DATE_PART('day', b.block_time - start_time) + DATE_PART('hour', b.block_time - start_time) / 24.0) as datediff_h
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
    and sender_address = any(array[fx.sender,fx.recipient])
)
cross join const
where 0 < balance_y
group by 1,2,3,4
order by 1
)

select date_bin('12 hours', wp.block_time, '2022-01-01') as interval
, max(wp.price) as price_max
, min(wp.price) as price_min
, avg(wp.price) as price_avg
, LEAST(0.75 + sum(volume) / 7e6, 1.4) as lerp_vol
, (power(1.04, power(avg(datediff_h), 0.76) / 6.0)) as projected_rate
from weighted wp
group by 1
order by 1
 