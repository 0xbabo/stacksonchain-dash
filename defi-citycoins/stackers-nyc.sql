with cycles as (
select (block_height - 60549)/2100 as cycle
, min(block_height) as first_block
, min(block_height)+2099 as last_block
from (SELECT generate_series(60549,1000000) as block_height) b
group by 1
)

, lock_period as (
select tx_hash
, sender_address
, replace(repr,'u','')::int as periods
, t.block_height
, first_block
, first_block + 2100*(replace(repr,'u','')::int-1) as last_stack_block
from transactions t 
join function_args f using (tx_hash)
join cycles c on t.block_height+2100 between first_block and last_block
where contract_call_contract_id = 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2'
and contract_call_function_name = 'stack-tokens'
and f.name='lockPeriod'
and status=1
)

, tokens as (
select tx_hash
, sender_address
, replace(repr,'u','')::numeric as amount
from transactions t 
join function_args f using (tx_hash)
where contract_call_contract_id = 'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.newyorkcitycoin-core-v2'
and contract_call_function_name = 'stack-tokens'
and f.name='amountTokens'
and status=1
)

select sender_address as address
, sum(amount)/1e6 as amount
from tokens t 
join lock_period l using(tx_hash, sender_address)
join cycles c on c.first_block between l.first_block and l.last_stack_block
where (select max(block_height) from blocks) between c.first_block and c.last_block
group by 1 
order by 2 desc
limit 30
