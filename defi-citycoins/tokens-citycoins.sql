with const as (
select 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null' as token_wstx_stsw -- 6D
    ,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx::wstx' as token_wstx_alex -- 8D
    ,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wmia::wmia' as token_wmia_alex -- 8D?
    ,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wnycc::wnycc' as token_wnyc_alex -- 8D?
    ,'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-token-v2::newyorkcitycoin' as token_nyc_v2
    ,'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-token-v2::miamicoin' as token_mia_v2
    ,'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-token::newyorkcitycoin' as token_nyc_v1
    ,'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-token::miamicoin' as token_mia_v1
)

, tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    cross join const
    where contract_id in (token_mia_v1,token_nyc_v1,token_mia_v2,token_nyc_v2)
)

, supply as (
    select asset_identifier, sum(total) as supply from (
        select asset_identifier, sum(amount) as total
        from ft_events
        cross join const
        right join tokens on (contract_id = asset_identifier)
        where (sender is null)
        group by 1
    union all
        select asset_identifier, sum(-amount) as total
        from ft_events
        cross join const
        right join tokens on (contract_id = asset_identifier)
        where (recipient is null)
        group by 1
    ) sub
    group by 1
)

, weighted as (
-- average price & liquidity over last N blocks
select null as nothing
, avg( stsw_mia1.balance_x / 1e6 * 1e6 ) as liq_mia_v1
, avg( stsw_nyc1.balance_x / 1e6 * 1e6 ) as liq_nyc_v1
, avg( stsw_mia2.balance_x/1e6 + alex_mia2.balance_x/1e8 ) as liq_mia_v2
, avg( stsw_nyc2.balance_x/1e6 + alex_nyc2.balance_x/1e8 ) as liq_nyc_v2
, avg( stsw_mia1.balance_x / stsw_mia1.balance_y :: numeric ) as price_mia1
, avg( stsw_nyc1.balance_x / stsw_nyc1.balance_y :: numeric ) as price_nyc1
, avg( ( stsw_mia2.balance_x/1e6 + alex_mia2.balance_x/1e8 ) 
    / ( stsw_mia2.balance_y/1e6 + alex_mia2.balance_y/1e8 ) ) as price_mia2
, avg( ( stsw_nyc2.balance_x/1e6 + alex_nyc2.balance_x/1e8 ) 
    / ( stsw_nyc2.balance_y/1e6 + alex_nyc2.balance_y/1e8 ) ) as price_nyc2
-- , sum(amount)/1e8 as volume
from blocks b
cross join last_block b0
cross join const
join dex.swap_balances stsw_mia1 on (stsw_mia1.token_x = token_wstx_stsw and stsw_mia1.token_y = token_mia_v1
    and stsw_mia1.block_height = b.block_height)
left join dex.swap_balances stsw_nyc1 on (stsw_nyc1.token_x = token_wstx_stsw and stsw_nyc1.token_y = token_nyc_v1
    and stsw_nyc1.block_height = b.block_height)
left join dex.swap_balances stsw_mia2 on (stsw_mia2.token_x = token_wstx_stsw and stsw_mia2.token_y = token_mia_v2
    and stsw_mia2.block_height = b.block_height)
left join dex.swap_balances stsw_nyc2 on (stsw_nyc2.token_x = token_wstx_stsw and stsw_nyc2.token_y = token_nyc_v2
    and stsw_nyc1.block_height = b.block_height)
left join dex.swap_balances alex_mia2 on (alex_mia2.token_x = token_wstx_alex and alex_mia2.token_y = token_wmia_alex
    and alex_mia2.block_height = b.block_height)
left join dex.swap_balances alex_nyc2 on (alex_nyc2.token_x = token_wstx_alex and alex_nyc2.token_y = token_wnyc_alex
    and alex_nyc2.block_height = b.block_height)
-- left join ft_events fx
-- where 0 < (lbtc_stx.balance_y + lbtc_stsw.balance_y)
where b.block_height > b0.block_height - 10
)

, liquidity as (
    select token_mia_v1 as token, price_mia1 as price, liq_mia_v1 as liquidity
    from weighted cross join const
union all
    select token_nyc_v1 as token, price_nyc1 as price, liq_nyc_v1 as liquidity
    from weighted cross join const
union all
    select token_mia_v2 as token, price_mia2 as price, liq_mia_v2 as liquidity
    from weighted cross join const
union all
    select token_nyc_v2 as token, price_nyc2 as price, liq_nyc_v2 as liquidity
    from weighted cross join const
)

select split_part(contract_id,'::',1) as "Explorer"
, replace(split_part(split_part(contract_id,'::',1),'.',2),'-token','') as name
, symbol, decimals
, to_char(supply / base, 'fm999G999G999G999G999D999') as "Circulating Supply"
, (supply / base * price) as "Market Cap (STX)"
, liquidity as "Liquidity (STX)"
from tokens
left join liquidity on (contract_id = token)
left join supply on (contract_id = asset_identifier)
order by "Market Cap (STX)" desc nulls last
