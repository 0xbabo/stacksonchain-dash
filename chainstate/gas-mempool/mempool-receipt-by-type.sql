with last_tx as (
select distinct on (sender_address) sender_address, nonce
from transactions tx
where exists (
    select * from mempool where sender_address = tx.sender_address
)
order by sender_address, nonce desc
)

select date_bin('30 min', receipt_time, b1.block_time) as receipt_time
, count(*) filter (
    where ((last.nonce is not null and mem.nonce > last.nonce) or (last.nonce is null and mem.nonce = 0))
    and tx_type = 'token_transfer') as token_transfer
, count(*) filter (
    where ((last.nonce is not null and mem.nonce > last.nonce) or (last.nonce is null and mem.nonce = 0))
    and tx_type = 'contract_call') as contract_call
, count(*) filter (
    where ((last.nonce is not null and mem.nonce > last.nonce) or (last.nonce is null and mem.nonce = 0))
    and tx_type = 'smart_contract') as smart_contract
, count(*) filter (
    where not ((last.nonce is not null and mem.nonce > last.nonce) or (last.nonce is null and mem.nonce = 0))
    ) as nonce_invalid
from mempool mem
left join last_tx last using (sender_address)
cross join last_block b1
where receipt_time > b1.block_time - interval '7 days'
and fee_rate > 0
group by 1
order by 1
