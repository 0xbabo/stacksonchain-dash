with const as ( select
    'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token::newyorkcitycoin' as nyc_v1,
    'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2::newyorkcitycoin' as nyc_v2
)

, tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties cross join const
    where contract_id in (
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx',
        nyc_v1, nyc_v2
    )
)

, swaps as (
    select * from transactions
    where status = 1 and tx_type = 'contract call'
	and contract_call_function_name like '%swap%'
    and ((contract_call_contract_id like 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%' and block_time < '2022-06-08')
        or contract_call_contract_id like 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%')
	and block_time > '2021-12-23T00:00:00Z'
)

select date_bin('24 hours', block_time, '2021-11-01') as interval
, max(fx.amount / fy.amount * tky.factor / tkx.factor ) * 10^3 as max_rate
, min(fx.amount / fy.amount * tky.factor / tkx.factor ) * 10^3 as min_rate
, avg(fx.amount / fy.amount * tky.factor / tkx.factor ) * 10^3 as avg_rate
, LEAST(-4e-3 + sum(fy.amount / tky.factor) / 5e9, 15e-3) * 10^3 as lerp_vol
, 0 as zero
, log( avg(fx.amount / fy.amount * tky.factor / tkx.factor) * 10^3 ) * 7.0 + 4.2 as lerp_log
from const cross join swaps trades
join ft_events fy on (trades.tx_id = fy.tx_id
    and (sender_address = fy.sender or sender_address = fy.recipient)
    and (fy.asset_identifier = nyc_v1 or fy.asset_identifier = nyc_v2))
join stx_events fx on (trades.tx_id = fx.tx_id
    and (sender_address = fx.sender or sender_address = fx.recipient))
join tokens tky on (tky.contract_id = fy.asset_identifier)
join tokens tkx on (tkx.contract_id like '%::wstx')
group by interval
