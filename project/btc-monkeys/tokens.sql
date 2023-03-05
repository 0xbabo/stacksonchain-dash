with const as (
select 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%' as contract_alex
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex' as token_alex -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx::wstx' as token_wstx -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wban::wban' as token_wban -- 8D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wslm::wslm' as token_wslm -- 8D
    , 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas::BANANA' as token_ban -- 6D
    , 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token::SLIME' as token_slm -- 6D
)

, tokens as (
select contract_id
, (properties ->> 'name') name
, (properties ->> 'symbol') symbol
, (properties ->> 'decimals') :: numeric decimals
, power(10, (properties ->> 'decimals') :: numeric) base
from token_properties
cross join const
where contract_id in (token_ban, token_slm)
)

, supply as (
with credit as (
select fx.asset_identifier, recipient as address
, sum(amount) as amount
from tokens tk
join ft_events fx on (fx.asset_identifier = tk.contract_id)
group by 1,2
)
, balance as (
select cr.asset_identifier, cr.address
, cr.amount - coalesce(debit.amount,0) as amount
from credit cr
left join lateral (
    select sum(fx.amount) as amount from ft_events fx
    where fx.asset_identifier = cr.asset_identifier
    and fx.sender = cr.address
) debit ON TRUE
)
select asset_identifier
, count(*) as users
, count(*) filter (where amount > 0) as holders
, sum(amount) as supply
from balance
join tokens on (contract_id = asset_identifier)
where address is not null
group by 1
)

, weighted as (
-- average price & liquidity over last N blocks
select avg( alex_stx.balance_x / alex_stx.balance_y :: numeric ) as price_alex
, avg( alex_stx.balance_x / alex_stx.balance_y :: numeric * ban_alex.balance_x / 1e8 ) as liq_ban
, avg( alex_stx.balance_x / alex_stx.balance_y :: numeric * slm_alex.balance_x / 1e8 ) as liq_slm
, avg( alex_stx.balance_x / alex_stx.balance_y :: numeric * ban_alex.balance_x / ban_alex.balance_y ) as price_ban
, avg( alex_stx.balance_x / alex_stx.balance_y :: numeric * slm_alex.balance_x / slm_alex.balance_y ) as price_slm
-- , sum(amount)/1e6 as volume
from blocks b
cross join last_block b0
cross join const
join dex.swap_balances alex_stx on (alex_stx.token_x = token_wstx and alex_stx.token_y = token_alex
    and alex_stx.block_height = b.block_height)
left join dex.swap_balances ban_alex on (ban_alex.token_x = token_alex and ban_alex.token_y = token_wban
    and ban_alex.block_height = b.block_height)
left join dex.swap_balances slm_alex on (slm_alex.token_x = token_alex and slm_alex.token_y = token_wslm
    and slm_alex.block_height = b.block_height)
-- left join ft_events fx
where 0 < (alex_stx.balance_y)
and b.block_height > b0.block_height - 10
)

, liquidity as (
    select token_ban as token, price_ban as price, liq_ban as liquidity
    from weighted cross join const
union all
    select token_slm as token, price_slm as price, liq_slm as liquidity
    from weighted cross join const
)

select split_part(contract_id,'::',1) as "Explorer"
, name, symbol, decimals
, users, holders
, to_char(supply / base, 'fm999G999G999G999G999D999') as "Circulating Supply"
, (supply / base * price) as "Market Cap (STX)"
, liquidity as "Liquidity (STX)"
from tokens
left join liquidity on (contract_id = token)
left join supply on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
