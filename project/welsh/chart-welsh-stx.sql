select date_bin(CASE WHEN block_time > now() - interval '7 days' THEN interval '1 hours' ELSE interval '6 hours' END
    , block_time, '2021-01-03') as interval
, max(fx.amount / fy.amount) * 1e6 as max_rate
, min(fx.amount / fy.amount) * 1e6 as min_rate
, avg(fx.amount / fy.amount) * 1e6 as avg_rate
, LEAST(-100e-6 + sum(fy.amount) / 1e6 / 5e12, 500e-6) * 1e6 as lerp_vol
, 0 as zero
, (log(avg(fx.amount / fy.amount)) + 6.0) * 150 as log_rate
from transactions tx
join ft_events fy
    on (tx.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient))
join stx_events fx
    on (tx.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient))
where fy.asset_identifier = 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token::welshcorgicoin'
and contract_call_contract_id like 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap%'
-- and contract_call_contract_id like 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap%'
-- and contract_call_contract_id = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.amm-swap-pool'
and contract_call_function_name like ANY(ARRAY['swap-%','router-swap'])
-- and block_time > now() - interval '1 month'
group by 1
order by 1
