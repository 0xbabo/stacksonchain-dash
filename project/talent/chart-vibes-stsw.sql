with tokens as (
select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
from token_properties
where contract_id in (
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null',
    'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw',
    'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token::vibes-token'
)
)

, swaps as (
select * from transactions
where status = 1 and tx_type = 'contract call'
and contract_call_function_name like '%swap%'
and contract_call_contract_id like 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%swap%'
-- and (block_time < '2022-03-14T00:00:00Z' or block_time > '2022-03-15T00:00:00Z') -- spurious events?
-- and fx.amount / fy.amount < 50 -- remove spurious trades
)

select to_char( date_bin(
    CASE WHEN block_time > now() - interval '7 days' THEN interval '1 hours' ELSE interval '24 hours' END
    , block_time, '2021-01-03'), 'YYYY-MM-DD"T"HH24"h"') as ts
, max(fx.amount / fy.amount * tky.factor / tkx.factor ) as max_rate
, min(fx.amount / fy.amount * tky.factor / tkx.factor ) as min_rate
, avg(fx.amount / fy.amount * tky.factor / tkx.factor ) as avg_rate
-- , LEAST(-0.3 + sum(fy.amount / tky.factor) / 70e3, 1.5) as lerp_vol
, 0 as zero
-- , log(avg(fx.amount / fy.amount * tky.factor / tkx.factor)) * 0.5 + 1.3 as log_rate
from swaps trades
join ft_events fy
    on (trades.tx_id = fy.tx_id and sender_address in (fy.sender, fy.recipient)
        and fy.asset_identifier = 'SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token::vibes-token')
join ft_events fx
    on (trades.tx_id = fx.tx_id and sender_address in (fx.sender, fx.recipient)
        and fx.asset_identifier = 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw')
join tokens tky
    on (tky.contract_id = fy.asset_identifier)
join tokens tkx
    on (tkx.contract_id = fx.asset_identifier)
group by 1
