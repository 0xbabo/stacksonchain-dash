with tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties
    where contract_id in (
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx',
        'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token::welshcorgicoin'
        --'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko'
        --'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda'
    )
), swaps as (
    select * from transactions
    where status = 1 and tx_type = 'contract call'
	and contract_call_function_name like 'swap-%'
    and contract_call_contract_id like 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.%'
	--and block_time > now() - interval '1 month'
    --and block_time > '2021-11-18T00:00:00Z'
)
select date_bin('1 hours', block_time, date_trunc('day',block_time)::timestamp) as interval,
    max(fx.amount / fy.amount * tky.factor / tkx.factor) * 1e6 as max_rate,
    min(fx.amount / fy.amount * tky.factor / tkx.factor) * 1e6 as min_rate,
    avg(fx.amount / fy.amount * tky.factor / tkx.factor) * 1e6 as avg_rate,
    LEAST(-100e-6 + sum(fy.amount / tky.factor) / 2e12, 500e-6) * 1e6 as lerp_vol,
    0 as zero,
    (log(avg(fx.amount / fy.amount * tky.factor / tkx.factor)) + 6.0) * 150 as log_rate
	from swaps txs
    join ft_events fy
        on (txs.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient))
    join stx_events fx
        on (txs.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient))
    join tokens tky
        on (tky.contract_id = fy.asset_identifier)
    join tokens tkx
        on (tkx.contract_id like '%::wstx')
    where fy.asset_identifier = 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token::welshcorgicoin'
    --and fx.amount / fy.amount * tky.factor / tkx.factor < 2.0 -- remove spurious events
    group by interval
