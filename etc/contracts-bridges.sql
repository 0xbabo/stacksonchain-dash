select 
    (select count(*) from transactions where contract_call_contract_id = sc.contract_id) as contract_calls,
    sc.contract_id,
    length(source_code) as src_len, length(abi::varchar) as abi_len,
    block_height as block_deployed,
    sc.contract_id as "Explorer"
from smart_contracts sc
full join token_properties tk on (contract = sc.contract_id)
where tk.contract_id ilike '%bridge%'
or tk.contract_id ilike '%wrapped%bitcoin%'
or tk.contract_id ilike '%wrapped%usd%'
or sc.contract_id ilike '%bridge%'
or sc.contract_id ilike '%multi%chain%'
or sc.contract_id ilike '%cross%chain%'
or sc.contract_id ilike '%orbit%'
order by contract_calls desc
limit 100
