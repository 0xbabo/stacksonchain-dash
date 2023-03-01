select contract_id as "Explorer"
, contract_id
-- , contract_call_function_name
, count(distinct tx.sender_address) as users
, count(distinct tx.tx_id) as txs
-- , sum(amount)/1e6 as "Vol (STX)"
from smart_contracts sc
left join transactions tx on (contract_call_contract_id = contract_id)
-- left join stx_events sx using (tx_id)
where contract_id like ANY(ARRAY
['SP8A9HZ3PKST0S42VM9523Z9NV42SZ026V4K39WH.%'
,'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.%'
,'SP466FNC0P7JWTNM2R9T199QRZN1MYEDTAR0KP27.%'
,'SPSCWDV3RKV5ZRN1FQD84YE1NQFEDJ9R1F4DYQ11.%'
,'SP2H8PY27SEZ03MWRKS5XABZYQN17ETGQS3527SA5.%'
])
group by 1,2
order by txs desc, users desc
limit 100
