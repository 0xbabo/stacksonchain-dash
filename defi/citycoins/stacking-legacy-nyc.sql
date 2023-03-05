with const as (
select 37449 as start_block
)

, contracts (contract_id,final_cycle,token_base) as (
VALUES('SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-core-v1',10,1e0)
    , ('SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2',28,1e6)
)

, lock_events as (
select tx_id
, block_height
, sender_address
, arg_lock.start as lock_start
, LEAST(arg_lock.period, final_cycle - arg_lock.start + 1) as lock_period
, arg_tokens.amount/token_base as locked_amount
from transactions tx
cross join const
join contracts on (contract_call_contract_id = contract_id)
join lateral (
    select right(repr,-1)::int as period
    , 1 + (tx.block_height - start_block) / 2100 as start
    from function_args fa where fa.tx_id = tx.tx_id
    and fa.name = 'lockPeriod'
) arg_lock ON TRUE
join lateral (
    select right(repr,-1)::numeric as amount
    from function_args fa where fa.tx_id = tx.tx_id
    and fa.name = 'amountTokens'
) arg_tokens ON TRUE
where contract_call_function_name = 'stack-tokens'
and status = 1
)

, poxl_info as (
select cycle_id
-- , count(distinct tx_id) as txs
-- , count(distinct sender_address) as stackers
, sum(locked_amount) as stacked
from lock_events lx
cross join const
join generate_series(1,50) cycle_id on (
    lock_start <= cycle_id and cycle_id < lock_start + lock_period
)
group by 1
order by 1
)

, daily as (
select token.ts::date as ts
, avg(stx.open + stx.high + stx.low + stx.close)/4 as stx_avg
, avg(token.open + token.high + token.low + token.close)/4 as token_avg
from prices.nyc_usd token
left join prices.stx_usd stx on (stx.ts::date = token.ts::date)
where token.timeframe = 'DAY'
and stx.timeframe = 'DAY'
group by 1
)

-- select cycle_id
select block_height - (block_height - start_block) % 300 as block_height
, stacked/1e2 as "TVL (100*NYC)"
, stacked * coalesce(avg(pp.token_avg),0) as "TVL (USD value)"
, stacked * coalesce(avg(pp.token_avg / pp.stx_avg),0) as "TVL (STX value)"
, cycle_id
from poxl_info
cross join const
join blocks bk on (cycle_id = (block_height - start_block) / 2100)
left join daily pp on (pp.ts = block_time::date)
-- where burn_block_height >= 668050
-- and stacked > 0
group by 1, stacked, cycle_id
order by 1
limit 500
