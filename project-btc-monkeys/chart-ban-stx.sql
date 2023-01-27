select date_bin('1 day', block_time, '2022-01-01')::date as interval
, max(fx.amount / fy.amount * 1) as max_rate
, min(fx.amount / fy.amount * 1) as min_rate
, avg(fx.amount / fy.amount * 1) as avg_rate
, LEAST(4.0, 0.0 + sum(fy.amount)/1e6 / 30e3) as lerp_vol
, log( avg(fx.amount / fy.amount * 1) ) * 1.0 + 1.2 as lerp_log
from transactions tx
join ft_events fy
    on (tx.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient))
join stx_events fx
    on (tx.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient))
where fy.asset_identifier = 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas::BANANA'
-- and fx.asset_identifier = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex')
and contract_call_function_name = 'swap-helper'
and contract_call_contract_id like 'SP3K8BC%0KBR9.swap%'
--and block_time > now() - interval '1 month'
group by interval
