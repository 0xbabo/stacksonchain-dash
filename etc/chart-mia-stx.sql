with const as ( select
    'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token::miamicoin' as mia_v1,
    'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin' as mia_v2
), tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties cross join const
    where contract_id in (
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx',
        mia_v1, mia_v2
    )
), swaps as (
    select * from transactions
    where status = 1 and tx_type = 'contract call'
	and contract_call_function_name like '%swap%'
    and ((contract_call_contract_id like 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%' and block_time < '2022-06-08')
        or contract_call_contract_id like 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%')
    and block_time > '2021-11-15T06:00:00Z'
)
select date_bin('12 hours', block_time, date_trunc('day',block_time)::timestamp) as interval,
    max(fx.amount / fy.amount * tky.factor / tkx.factor ) * 10^3 as max_rate,
    min(fx.amount / fy.amount * tky.factor / tkx.factor ) * 10^3 as min_rate,
    avg(fx.amount / fy.amount * tky.factor / tkx.factor ) * 10^3 as avg_rate,
    LEAST(-3e-3 + sum(fy.amount / tky.factor) / 4e9, 15e-3) * 10^3 as lerp_vol,
    0 as zero
	from const cross join swaps trades
    join ft_events fy
        on (trades.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient)
            and fy.asset_identifier in (mia_v1, mia_v2))
    join stx_events fx
        on (trades.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient))
    join tokens tky on (tky.contract_id = fy.asset_identifier)
    join tokens tkx on (tkx.contract_id like '%::wstx')
    group by interval
