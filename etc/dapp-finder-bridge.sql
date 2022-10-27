select 
    sc.contract_id,
    (select count(*) from transactions where contract_call_contract_id = sc.contract_id) as calls,
    (select count(*) from (select sender_address from transactions where contract_call_contract_id = sc.contract_id
        group by sender_address) sub_users) as users,
    length(source_code) as src_len,
    length(abi::varchar) as abi_len,
    block_height as block_deployed,
    sc.contract_id as "Explorer"
from smart_contracts sc
full join token_properties tk on (contract = sc.contract_id)
-- join transactions tx on (contract_call_contract_id = sc.contract_id)
where tk.contract_id ilike '%bridge%'
or tk.contract_id ilike '%wrapped%bitcoin%'
or tk.contract_id ilike '%wrapped%usd%'
or sc.contract_id ilike '%bridge%' -- satoshibles, etc
or sc.contract_id ilike '%cross%chain%' -- etc
or sc.contract_id ilike '%multi%chain%' -- stackswap
or sc.contract_id ilike '%orbit%' -- orbit
or sc.contract_id like 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%swap%' -- lnswap
or sc.contract_id like 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%resolver%' -- lnswap oracle
or sc.contract_id like '%oracle%' -- etc
order by 2 desc
limit 100
