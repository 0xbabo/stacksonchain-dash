with const as (
    select '2022-04-26T00:00:00Z'::timestamp as start_time
), tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties
    where contract_id in (
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex'
    )
), swaps as (
    select *,
        (DATE_PART('day', block_time - start_time) + DATE_PART('hour', block_time - start_time) / 24.0)
            as datediff_h
    from transactions cross join const
    where status = 1 and tx_type = 'contract call'
	and contract_call_function_name = 'swap-helper'
    and contract_call_contract_id like 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%'
	--and block_time > now() - interval '1 month'
)
select date_bin('6 hours', block_time, date_trunc('day',block_time)::timestamp) as interval,
    max(fx.amount / fy.amount * tky.factor / tkx.factor) as max_rate,
    min(fx.amount / fy.amount * tky.factor / tkx.factor) as min_rate,
    avg(fx.amount / fy.amount * tky.factor / tkx.factor) as avg_rate,
    LEAST(0.75 + sum(fy.amount / tky.factor) / 7e6, 1.4) as lerp_vol,
    (power(1.015, power(avg(datediff_h), 0.86) / 3.5)) as projected_rate
from swaps txs
join ft_events fy
    on (txs.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient))
join ft_events fx
    on (txs.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient))
join tokens tky on (tky.contract_id = fy.asset_identifier)
join tokens tkx on (tkx.contract_id = fx.asset_identifier)
where fy.asset_identifier = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex'
and fx.asset_identifier = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex'
group by interval
