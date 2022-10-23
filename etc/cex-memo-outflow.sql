with stx_outflow as (
    select sender_address as sender
    , token_transfer_recipient_address as recipient
    , count(*) as num_txs
    , sum(token_transfer_amount)/1e6 as volume
    from transactions
    where tx_type = 'token transfer'
    group by 1, 2
    -- order by 3
)

select sender as address
, sum(volume) as "Volume (STX)"
, sum(num_txs) as num_txs
, count(*) as num_users
, total as "Balance (STX)"
from stx_outflow
join accounts on (account = sender)
group by 1, 5
having count(*) >= 64
    and sum(volume) >= 1e6
    -- and total >= 100e3
order by 2 desc
limit 100
