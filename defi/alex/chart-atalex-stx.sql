with const as (
select 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%' as contract_alex
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx::wstx' as token_wstx -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex' as token_alex -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex' as token_auto -- 8D
)

, weighted as (
select b.block_height, b.block_time
, ( alex_stx.balance_x / alex_stx.balance_y :: numeric * auto_alex.balance_x / auto_alex.balance_y ) as price
-- , sum(amount)/1e6 as volume
from blocks b
cross join const
join dex.swap_balances auto_alex on (auto_alex.token_x = token_alex and auto_alex.token_y = token_auto
    and auto_alex.block_height = b.block_height)
left join dex.swap_balances alex_stx on (alex_stx.token_x = token_wstx and alex_stx.token_y = token_alex
    and alex_stx.block_height = b.block_height)
-- left join ft_events fx
where 0 < (alex_stx.balance_y)
-- group by 1,2,3
order by 1
)

select date_bin('12 hours', wp.block_time, '2022-01-01') as interval
, max(wp.price) as price_max
, min(wp.price) as price_min
, avg(wp.price) as price_avg
-- , LEAST(0.0 + sum(volume) / 5e6, 0.7) as lerp_vol
, 0 as lerp_vol
, log( avg(price) ) * 0.5 + 0.7 as lerp_log
from weighted wp
group by 1
order by 1
