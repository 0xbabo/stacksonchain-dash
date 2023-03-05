select block_time::date as ts
-- , count(*) as events
-- , count(distinct tx_id) as txs
, count(distinct recipient) as recipients
, sum(amount)/1e8 as amount
from transactions tx
join ft_events fx using (tx_id,block_height)
where contract_call_contract_id = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.autoalex-apower-helper'
and contract_call_function_name = 'mint-and-burn-apower'
and asset_identifier = 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.token-apower::apower'
group by 1
order by 1
