select right(arg_del.repr,-1) as "Explorer"
, right(arg_del.repr,-1) as pool
, count(distinct sender_address) as users
, count(*) as txs
from transactions tx
join function_args arg_del on (
    arg_del.tx_id = tx.tx_id 
    and arg_del.name = ANY(ARRAY['caller','delegate-to'])
    -- and right(arg_del.repr,-1) like '%.boombox%'
)
where contract_call_contract_id = 'SP000000000000000000002Q6VF78.pox'
and contract_call_function_name = ANY(ARRAY['allow-contract-caller','delegate-stx'])
group by 1,2
-- having count(*) > 1
order by txs desc
limit 100
