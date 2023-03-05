with const as (
select 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stackswap-swap-v5k' as contract_stackswap
    ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null' as token_wstx -- 6D
    ,'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw' as token_stsw -- 6D
    , 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn::fari' as token_fari
)

, tokens as (
select contract_id
, (properties ->> 'name') name
, (properties ->> 'symbol') symbol
, (properties ->> 'decimals') :: numeric decimals
, power(10, (properties ->> 'decimals') :: numeric) base
from token_properties
cross join const
where contract_id in (token_fari)
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
select avg( fari_stx.balance_x/1e8 + fari_stsw.balance_x/1e8 * stsw_stx.balance_x / stsw_stx.balance_y ) as liq_fari
, avg( ( fari_stx.balance_x/1e8 + fari_stsw.balance_x/1e8 * stsw_stx.balance_x / stsw_stx.balance_y ) 
    / ( fari_stx.balance_y/1e8 + fari_stsw.balance_y/1e8 ) ) as price_fari
-- , sum(amount)/1e8 as volume
from blocks b
cross join last_block b0
cross join const
join dex.swap_balances stsw_stx on (stsw_stx.token_x = token_wstx and stsw_stx.token_y = token_stsw
    and stsw_stx.block_height = b.block_height)
left join dex.swap_balances fari_stx on (fari_stx.token_x = token_wstx and fari_stx.token_y = token_fari
    and fari_stx.block_height = b.block_height)
left join dex.swap_balances fari_stsw on (fari_stsw.token_x = token_stsw and fari_stsw.token_y = token_fari
    and fari_stsw.block_height = b.block_height)
-- left join ft_events fx
where 0 < (fari_stx.balance_y + fari_stsw.balance_y)
and b.block_height > b0.block_height - 10
)

, liquidity as (
    select token_fari as token, price_fari as price, liq_fari as liquidity
    from weighted cross join const
)

select split_part(contract_id,'::',1) as "Explorer"
, name, symbol, decimals
, users, holders
, to_char(supply / base, 'fm999G999G999G999G999D999') as "Circulating Supply"
-- , (supply / base * price) as "Market Cap (STX)"
, liquidity as "Liquidity (STX)"
from tokens
left join liquidity on (contract_id = token)
left join supply on (contract_id = asset_identifier)
-- order by "Market Cap (STX)" desc nulls last
