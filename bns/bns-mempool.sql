select receipt_time
, fee_rate/1e6 as fee
, encode(decode(right(payload #> '{function_args,1}' ->> 'repr', -2), 'hex'), 'escape')
    ||'.'|| encode(decode(right(payload #> '{function_args,0}' ->> 'repr', -2), 'hex'), 'escape') as fqn
, CASE WHEN left(encode(decode(right(payload #> '{function_args,1}' ->> 'repr', -2), 'hex'), 'escape'),4) = 'xn--'
    THEN idn_punycode_decode(right(encode(decode(right(payload #> '{function_args,1}' ->> 'repr', -2), 'hex'), 'escape'),-4))
    ||'.'|| encode(decode(right(payload #> '{function_args,0}' ->> 'repr', -2), 'hex'), 'escape')
    END as depunycode
from mempool mx
where tx_type = 'contract_call'
and payload ->> 'contract_id' = 'SP000000000000000000002Q6VF78.bns'
and payload ->> 'function_name' = 'name-register'
-- and status=1
order by 1 desc
limit 500
