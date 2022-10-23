with stx_inflow_memo as (
    select token_transfer_recipient_address as address
    , token_transfer_memo as memo
    , count(*) as num_txs
    , sum(token_transfer_amount)/1e6 as volume
    from transactions
    where tx_type = 'token transfer'
    group by 1, 2
    -- order by 3
)

select address
, sum(volume) as "Volume (STX)"
, sum(num_txs) as num_txs
, count(*) as num_memo
, total as "Balance (STX)"
from stx_inflow_memo
join accounts on (account = address)
group by 1, 5
having count(*) >= 64
    -- and sum(volume) >= 1e6
    -- and total >= 100e3
order by 2 desc
limit 100
