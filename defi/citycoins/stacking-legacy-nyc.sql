with contracts (contract_id,start_block,final_cycle,token_base) as (
VALUES('SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.newyorkcitycoin-core-v1',37449,10,1e0)
    , ('SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2',37449,28,1e6)
)

, lock_events as (
select tx_id
, block_height
, sender_address
, arg_lock.start as lock_start
, LEAST(arg_lock.period, final_cycle - arg_lock.start + 1) as lock_period
, arg_tokens.amount/token_base as locked_amount
from transactions tx
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

select cycle
-- , count(distinct tx_id) as txs
-- , count(distinct sender_address) as stackers
, sum(locked_amount) as amount
from lock_events lx
join generate_series(1,50) cycle on (
    lock_start <= cycle and cycle < lock_start + lock_period
)
group by 1
order by 1
