with tokens (asset_id,base) as (
VALUES('SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token::miamicoin',1)
    , ('SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin',1e6)
)

select to_char(
    date_bin(CASE WHEN block_time > now() - interval '7 days' THEN interval '1 hours' ELSE interval '24 hours' END
    , block_time, '2021-01-03')
    , 'YYYY-MM-DD"T"HH24"h"') as interval
, LEAST( 12, max(fx.amount / fy.amount * tk.base / 1e6 ) * 1e3 ) as max_rate
, LEAST( 12, min(fx.amount / fy.amount * tk.base / 1e6 ) * 1e3 ) as min_rate
, LEAST( 12, avg(fx.amount / fy.amount * tk.base / 1e6 ) * 1e3 ) as avg_rate
, LEAST(-4e-3 + sum(fy.amount / tk.base) / 5e9, 15e-3) * 1e3 as lerp_vol
, 0 as zero
, LEAST( 12, log( avg(fx.amount / fy.amount * tk.base / 1e6) * 1e3 ) * 7.0 + 4.2 ) as lerp_log
from transactions tx
join ft_events fy
    on (tx.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient))
join stx_events fx
    on (tx.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient))
join tokens tk on (tk.asset_id = fy.asset_identifier)
where contract_call_contract_id like ANY(ARRAY
['SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap%'
,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%'
-- ,'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-swap%'
])
and contract_call_function_name like ANY(ARRAY['swap-%','router-swap'])
group by 1
order by 1
