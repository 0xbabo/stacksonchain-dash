with last_tx as (
select distinct on (sender_address) sender_address, nonce
from transactions tx
where exists (
    select * from mempool where sender_address = tx.sender_address
)
order by sender_address, nonce desc
)

select tx_id as "Explorer"
, date_trunc('second',age(now(),receipt_time))::text as age
, fee_rate/1e6 as fee
, pg_column_size(payload) as tx_size
, round(fee_rate/pg_column_size(payload)::numeric,3) as ustx_per_byte
, mem.nonce
, last.nonce as nonce_last
, ((last.nonce is not null and mem.nonce > last.nonce) or (last.nonce is null and mem.nonce = 0)) :: text as nonce_ok
, left(sender_address,5) ||'...'|| right(sender_address,5) as sender_address
, tx_type
, left(split_part(payload ->> 'contract_id','.',1),5) ||'...'|| right(split_part(payload ->> 'contract_id','.',1),5)
    ||'.'|| split_part(payload ->> 'contract_id','.',2) as contract_id
, payload ->> 'function_name' as function_name
from mempool mem
left join last_tx last using (sender_address)
where receipt_time > now() - interval '7 days'
order by 5 desc
limit 100
