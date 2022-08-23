with tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties
    where contract_id in (
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null',
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw',
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.lbtc-token-v1c::lbtc'
    )
), swaps as (
    select * from transactions
    where status = 1 and tx_type = 'contract call'
	and contract_call_function_name like '%swap%'
	and contract_call_contract_id like 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%swap%'
	--and block_time > now() - interval '1 month'
)
select date_bin('24 hours', block_time, date_trunc('day',block_time)::timestamp) as interval,
    max(fx.amount / fy.amount * tky.factor / tkx.factor ) as max_rate,
    min(fx.amount / fy.amount * tky.factor / tkx.factor ) as min_rate,
    avg(fx.amount / fy.amount * tky.factor / tkx.factor ) as avg_rate,
    LEAST(0.1 + sum(fy.amount / tky.factor) / 20e6, 0.3) as lerp_vol,
    log( avg(fx.amount / fy.amount * tky.factor / tkx.factor) ) * 0.3 + 0.42 as lerp_log
	from swaps txs
    join ft_events fy
        on (txs.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient)
            and fy.asset_identifier = 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw')
    join stx_events fx
        on (txs.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient)
            )--and fx.asset_identifier = 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null')
    join tokens tky
        on (tky.contract_id = fy.asset_identifier)
    join tokens tkx
        on (tkx.contract_id = 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null')
    group by interval
