with tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties
    where contract_id in (
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex',
        'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas::BANANA',
        'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token::SLIME'
    )
)
select date_bin('6 hours', block_time, date_trunc('day',block_time)::timestamp) as interval,
    max(fx.amount / fy.amount * tky.factor / tkx.factor) as max_rate,
    min(fx.amount / fy.amount * tky.factor / tkx.factor) as min_rate,
    avg(fx.amount / fy.amount * tky.factor / tkx.factor) as avg_rate,
    LEAST(0.1 + sum(fy.amount / tky.factor) / 50e3, 4.0) as lerp_vol
	from transactions txs
    join ft_events fy
        on (txs.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient)
            and fy.asset_identifier = 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas::BANANA')
    join stx_events fx
        on (txs.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient)
            )--and fx.asset_identifier = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex')
    join tokens tky
        on (tky.contract_id = fy.asset_identifier)
    join tokens tkx
        on (tkx.contract_id = 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null')
    where status = 1 and tx_type = 'contract call'
	and contract_call_function_name = 'swap-helper'
    and contract_call_contract_id like 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap%'
	--and block_time > now() - interval '1 month'
    group by interval
