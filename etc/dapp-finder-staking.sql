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
-- full join token_properties tk on (contract = sc.contract_id)
-- join transactions tx on (contract_call_contract_id = sc.contract_id)
where sc.contract_id like '%.%stak%'
or sc.contract_id like '%.%stacker%'
or sc.contract_id like '%.%poxl%' -- Stackswap POXL
or sc.contract_id like '%.%coin-core%' -- CityCoins
-- and sc.contract_id not like '%' -- blah
order by 2 desc
limit 100
