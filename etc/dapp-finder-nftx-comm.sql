select right(fa.repr,-1) as "Explorer"
, right(fa.repr,-1) as fa_comm
-- select split_part(right(fa.repr,-1),'.',1) as fa_comm_deployer
-- , fa.name as fa_name
-- , contract_call_contract_id
-- , contract_call_function_name
, count(distinct fa.repr) as comm_traits
, count(distinct contract_call_contract_id) as contracts
, count(distinct sender_address) as users
, count(distinct tx_id) as txs
, sum(amount::numeric)/1e6 as "Total Vol (STX)"
from function_args fa
join transactions tx using (tx_id)
join stx_events sx using (tx_id)
where fa.type = 'trait_reference'
and fa.name like 'comm%'
group by 1,2
order by "Total Vol (STX)" desc, txs desc
limit 100
