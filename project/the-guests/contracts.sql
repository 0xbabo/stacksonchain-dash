select contract_call_contract_id as "Explorer"
, contract_call_contract_id
-- , contract_call_function_name
, count(distinct sender_address) as users
, count(*) as txs
from transactions
where contract_call_contract_id like ANY(
-- VALUES ('%guests%')
VALUES ('SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.the-guests')
, ('SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.guests-hosted-stacks-parrots')
, ('SP1XPG9QFX5M95G36SGN9R8YJ4KJ0JB7ZXNH892N6.the-lolas')
, ('SP2QDMH88MEZ8FFAYHW4B0BTXJRTHX8XBD54FE7HJ.degen-naming-service')
, ('SP3K22XKPT9WJFCE957J94J6XXVZHP7747YNPDTFD.the-guests-stacks-dads')
, ('SP3252T1HMQHZTA9S22WZ2HZMKC4CVH965SHSERTH.%')
, ('SP3SC5PSKQM9ABTYPNYDV1J7SBGHA08VRW1DKTJK6.%')
, ('SPJSCH3DDEJ8GQPGYZBHSB4F3HX5Q222CG89PSAB.%')
)
group by 2
order by users desc, txs desc
limit 100
