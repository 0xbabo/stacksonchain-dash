with last_tx as (
select distinct on (sender_address) sender_address, nonce
from transactions tx
where exists (
    select * from mempool where sender_address = tx.sender_address
)
order by 1, 2 desc
)

select count(*) as "mempool txs"
, count(*) filter (
    where ((last.nonce is not null and mem.nonce > last.nonce) or (last.nonce is null and mem.nonce = 0))
    ) as "nonce ok"
from mempool mem
left join last_tx last using (sender_address)
