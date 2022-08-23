with const as ( select
    '2022-04-26T00:00:00Z'::timestamp as start_time,
    'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.wrapped-lydian-token::wrapped-lydian' as ft_wldn,
    'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.lydian-token::lydian' as ft_ldn
), tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties
    cross join const
    where contract_id in (
        ft_wldn, ft_ldn
    )
), swaps as (
    select *
    from transactions
    cross join const
    where status = 1 and tx_type = 'contract call'
	-- and contract_call_function_name = 'swap-helper'
    and contract_call_contract_id like 'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.%'
	--and block_time > now() - interval '1 month'
)
select date_bin('6 hours', block_time, date_trunc('year',block_time)::timestamp) as interval,
    max(fx.amount / fy.amount * tky.factor / tkx.factor * ps.price) as max_rate,
    min(fx.amount / fy.amount * tky.factor / tkx.factor * ps.price) as min_rate,
    avg(fx.amount / fy.amount * tky.factor / tkx.factor * ps.price) as avg_rate
    -- LEAST(0.75 + sum(fy.amount / tky.factor) / 7e6, 1.4) as lerp_vol,
	from swaps txs
    join ft_events fy
        on (txs.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient))
    join ft_events fx
        on (txs.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient))
    join tokens tky on (tky.contract_id = fy.asset_identifier)
    join tokens tkx on (tkx.contract_id = fx.asset_identifier)
    join prices.dex_tokens_stx ps on (ps.ts = date_trunc('hour',block_time)::timestamp)
    -- cross join const
    where fy.asset_identifier = ft_wldn
    and fx.asset_identifier = ft_ldn
    and ps.timeframe = 'HOUR'
    and ps.token = ft_ldn
    group by interval
