select contract_call_contract_id as "Explorer"
, contract_call_contract_id
-- , contract_call_function_name
, count(distinct sender_address) as users
, count(tx_id) as txs
, sum(amount::numeric)/1e6 as "Total Vol (STX)"
from transactions tx
left join stx_events sx using (tx_id)
where contract_call_function_name ilike any(array[
'buy%','purchase%','list%','unlist%','%bid%','%offer%'
-- ,'mint%','claim%'
])
-- and not contract_call_function_name ilike any(array[
-- 'claim%reward%','claim%stak%','claim%farm%','claim%debt','claim%pool','claim%position%'
-- ])
-- and not contract_call_contract_id like any(array[
-- 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%' -- lnswap::claimStx,claimToken
-- ,'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%' -- ALEX launchpad & auto-alex
-- ])
group by 1,2
order by txs desc, users desc
limit 100
