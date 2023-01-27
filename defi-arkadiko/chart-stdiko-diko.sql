with const as (
select '2022-04-26T00:00:00Z'::timestamp as start_time
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token::diko' as ft_diko
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.stdiko-token::stdiko' as ft_stdiko
    , 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-stake-registry-%' as contract_like
)

, swaps as (
    select tx.block_height, tx.block_time, tx.id, sender_address
    , 1e-6 * sum(fx.amount) as amount_x
    , 1e-6 * sum(fy.amount) as amount_y
    from transactions tx
    cross join const
    join ft_events fx on (fx.tx_id = tx.tx_id and fx.asset_identifier = ft_diko
        and sender_address = any(array[fx.sender, fx.recipient]))
    join ft_events fy on (fy.tx_id = tx.tx_id and fy.asset_identifier = ft_stdiko)
    where status = 1
    and contract_call_contract_id like contract_like
    group by 1,2,3,4
)

select date_bin('1 day', block_time, '2022-01-01')::date as interval
, max(amount_x / amount_y) as index
from swaps
group by 1
order by 1
