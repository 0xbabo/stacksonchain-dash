with tokens (token_x,base_x,token_y,base_y) as (VALUES
    (null, 1e6 -- STX
    ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw', 1e6
))

, calls (contract_like,function_like) as (VALUES
    ('SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v%','swap-%-for-%'),
    ('SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-router-%','router-swap')
)

, swaps as (
    select tx_id, block_height, block_time, sender_address
    from transactions
    join calls on (
        contract_call_contract_id like contract_like
        and contract_call_function_name like function_like
    )
    where status = 1
    -- and tx_type = 'contract call'
	-- and block_time > now() - interval '1 month'
)

select date_bin('24 hours', block_time, date_trunc('month',now())) as interval
, max(fx.amount / fy.amount * base_y / base_x ) as max_rate
, min(fx.amount / fy.amount * base_y / base_x ) as min_rate
, avg(fx.amount / fy.amount * base_y / base_x ) as avg_rate
, LEAST(0.075 + sum(fy.amount / base_y) / 20e6, 0.3) as lerp_vol
, log( avg(fx.amount / fy.amount * base_y / base_x) ) * 0.25 + 0.385 as lerp_log
from swaps tx
cross join tokens tk
join ft_events fy on (fy.tx_id = tx.tx_id and tx.sender_address = any(array[fy.sender,fy.recipient])
    and fy.asset_identifier = tk.token_y)
join stx_events fx on (fx.tx_id = tx.tx_id and tx.sender_address = any(array[fx.sender,fx.recipient]))
group by interval
