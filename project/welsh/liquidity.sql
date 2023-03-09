with const as (
select 'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token::welshcorgicoin' as token_welsh -- 6D
    , 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-wstx::wstx' as token_wstx_alex -- 8D
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.wrapped-stx-token::wstx' as token_wstx_arkadiko -- 6D
    , 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.wstx-token-v4a::null' as token_wstx_stackswap -- 6D
    , 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.stsw-token-v4a::stsw' as token_stsw -- 6D
)

, liquidity as (
select contract_id, token_x, token_y
, coalesce( pool->>'liquidity-token', pool->>'swap-token', pool->>'pool-token' ) as pool_token
, avg(balance_x) as balance_x
, avg(balance_y) as balance_y
from dex.coin_contract_prices
where block_height > get_max_block() - 10
and balance_x is not null and balance_y is not null
and length(pool::text) > 2 -- empty json?
group by 1,2,3,4
)

, tvl as (
select welsh_stsw.pool_token as pool_token
, 2 * welsh_stsw.balance_x/1e6 * stsw_stx.balance_x / stsw_stx.balance_y as tvl_stx
from const
cross join liquidity stsw_stx
cross join liquidity welsh_stsw
where (stsw_stx.token_x = token_wstx_stackswap and stsw_stx.token_y = token_stsw)
and (welsh_stsw.token_x = token_stsw and welsh_stsw.token_y = token_welsh)
    UNION ALL
select welsh_stx.pool_token as pool_token_id
, 2 * welsh_stx.balance_x/1e6 as tvl_stx
from const
cross join liquidity welsh_stx
where (welsh_stx.token_x = token_wstx_arkadiko and welsh_stx.token_y = token_welsh)
    UNION ALL
select 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-amm-swap-pool' as pool_token
, null as tvl_stx
)

select pool_token as "Explorer"
, split_part(pool_token,'.',2) as pool_token
, tvl_stx as "TVL (STX)"
from tvl
order by 3 desc nulls last
