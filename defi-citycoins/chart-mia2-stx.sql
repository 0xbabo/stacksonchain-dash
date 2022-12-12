with tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties
    where contract_id in (
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null',
        'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin'
        --'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token::miamicoin'
    )
)

, swaps as (
    select * from transactions
	where status = 1 and tx_type = 'contract call'
	and contract_call_contract_id like 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%'
	and contract_call_function_name = 'swap-helper'
	--and block_time > now() - interval '1 month'
)

select date_bin('12 hours', block_time, '2022-01-01') as interval
, max(fx.amount / fy.amount * tky.factor / tkx.factor ) * 1e3 as max_rate
, min(fx.amount / fy.amount * tky.factor / tkx.factor ) * 1e3 as min_rate
, avg(fx.amount / fy.amount * tky.factor / tkx.factor ) * 1e3 as avg_rate
, LEAST(0.0 + sum(fy.amount / tky.factor) / 10e9, 5e-3) * 1e3 as lerp_vol
-- , log( avg(fx.amount / fy.amount * tky.factor / tkx.factor) ) * 0.3 + 0.4 as lerp_log
from swaps txs
join ft_events fy
    on (txs.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient)
        and fy.asset_identifier = 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin')
join stx_events fx
    on (txs.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient)
        )--and fx.asset_identifier = 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null')
join tokens tky
    on (tky.contract_id = fy.asset_identifier)
join tokens tkx
    on (tkx.contract_id = 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null')
group by interval
