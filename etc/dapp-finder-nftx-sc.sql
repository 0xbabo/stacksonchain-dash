select contract_call_contract_id
, count(distinct sender_address) as users
, count(distinct tx_id) as txs
, sum(amount)/1e6 as "Total Vol (STX)"
from transactions tx
left join stx_events sx using (tx_id)
where contract_call_function_name like any(array[
'buy%','purchase%','list%','unlist%','%-bid'
])
group by 1
order by txs desc, users desc
limit 100
