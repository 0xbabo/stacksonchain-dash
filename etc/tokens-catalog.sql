with const as ( select
    'SPVRC3RHFD58B2PY1HZD2V71THPW7G445WBRCQYW.octopus_v01' as stackswap_locker,
    'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-diko-init' as arkadiko_locker
)
, tokens as (
    select contract_id as asset_identifier,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    --where contract_id in (...)
)
, token_flow as (
    select account, asset_identifier, sum(amount) as balance from (
        select recipient as account, asset_identifier, sum(amount) as amount
        from ft_events
        group by 1, 2
    union all
        select sender as account, asset_identifier, -sum(amount) as amount
        from ft_events
        group by 1, 2
    ) sub
    group by 1, 2
)
, token_supply as (
    select asset_identifier,
        split_part(asset_identifier,'.',2) as contract_name,
        sum(balance) as supply,
        count(*) as users
    from token_flow
    cross join const
    where account not in (stackswap_locker, arkadiko_locker) -- NOTE: BYPASSES CHECK FOR NULL ADDRESS (MINT/BURN)
    group by 1
)
, token_prices as (
    select distinct on (1) token as asset_identifier, price
    from prices.dex_tokens_stx
	order by 1, ts desc
)
, token_pools as (
    select distinct on (contract_id, token_x, token_y) token_x, token_y, balance_x, balance_y
    from prices.swap_balances
    order by contract_id, token_x, token_y, block_height desc
)
, token_liquidity as (
    select tk.asset_identifier,
        sum(CASE WHEN tk.asset_identifier = token_x THEN balance_x ELSE balance_y END / tky.base * tk.base) as liquidity
    from tokens tk
    join token_pools on (tk.asset_identifier in (token_x, token_y))
    join tokens tky on (tky.asset_identifier = token_y) -- balances both use decimals from token_y
    group by tk.asset_identifier
)
select
    CASE WHEN symbol is null THEN null ELSE format('%s (%s)', name, symbol) END as name_symbol,
    CASE WHEN length(contract_name) > 20 and strpos(left(contract_name,20),'-') = 0
        THEN left(contract_name,17)||'...'
        ELSE contract_name END as contract_name,
    decimals,
    users,
    CASE WHEN base is null THEN supply::varchar
        ELSE to_char( supply / base, 'fm999G999G999G999G999G999D999')
        END as "Circulating Supply",
    (supply / base * price) as "Market Cap (STX)",
    (liquidity / base * price) as "Liquidity (STX)",
    block_height as genesis,
    contract_id as "Explorer"
from tokens
full join token_prices using (asset_identifier)
full join token_liquidity using (asset_identifier)
full join token_supply using (asset_identifier)
left join smart_contracts on (contract_id = split_part(asset_identifier,'::',1))
where users > 2
order by users desc nulls last
