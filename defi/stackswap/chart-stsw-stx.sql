with contracts (swap_like,lp_id,token_x,token_y,functions_like) as (VALUES
('SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-%'
, 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.liquidity-token-stx-stsw'
, 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null' -- 6D
, 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw' -- 6D
, array['router-swap','swap-%']
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
    and lp_id = any(array[fx.sender,fx.recipient])
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
, -0.05 + coalesce(sum(volume),0) / 3e7 as lerp_vol
, 0 as zero
, log( avg(price) ) * 0.20 + 0.385 as lerp_log
-- , 2*avg(balance_x)/1e6/1e7 as liquidity_scaled
from weighted wp
group by 1
order by 1
