with tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties
    where contract_id in (
        'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex'
    )
)

select date_bin('12 hours', block_time, '2022-01-01') as interval
, max(fx.amount / fy.amount * tky.factor / tkx.factor) as max_rate
, min(fx.amount / fy.amount * tky.factor / tkx.factor) as min_rate
, avg(fx.amount / fy.amount * tky.factor / tkx.factor) as avg_rate
, LEAST(0.0 + sum(fy.amount / tky.factor) / 5e6, 0.7) as lerp_vol
, log( avg(fx.amount / fy.amount * tky.factor / tkx.factor) ) * 0.5 + 0.7 as lerp_log
from transactions txs
join ft_events fy
    on (txs.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient)
        and fy.asset_identifier = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex')
join stx_events fx
    on (txs.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient)
        )--and fx.asset_identifier = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex')
join tokens tky
    on (tky.contract_id = fy.asset_identifier)
join tokens tkx
    on (tkx.contract_id like '%::wstx')
where status = 1 and tx_type = 'contract call'
and contract_call_function_name = 'swap-helper'
and contract_call_contract_id like 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.swap%'
--and block_time > now() - interval '1 month'
group by interval
