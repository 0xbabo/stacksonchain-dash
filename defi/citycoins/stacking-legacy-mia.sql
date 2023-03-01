with contracts (contract_id,start_block,final_cycle,token_base) as (
VALUES('SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.miamicoin-core-v1',24497,16,1e0)
    , ('SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.miamicoin-core-v2',24497,34,1e6)
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
