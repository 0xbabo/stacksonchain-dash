select contract_call_contract_id as "Explorer"
, CASE WHEN EXISTS (select 1 from NFT_EVENTS where split_part(asset_identifier,'::',1) = contract_call_contract_id)
    THEN '<a href="https://gamma.io/collections/' || contract_call_contract_id || '">Gamma</a>'
    END as "Market"
, split_part(contract_call_contract_id,'.',2) as contract_id
, count(distinct sender_address) as users
, count(*) as txs
from transactions tx
where contract_call_contract_id like ANY(ARRAY
['SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.the-guests'
,'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.guests-hosted-stacks-parrots'
,'SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.the-lolas'
,'SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.degen-naming-service'
,'SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.the-guests-stacks-dads'
,'SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.%'
,'SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6.%'
,'SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB.%'
])
group by contract_call_contract_id
order by users desc, txs desc
limit 100
