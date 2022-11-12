with ft_prop as (
    select contract as contract_id
    , contract_id as asset_identifier
    , pow(10, (properties->>'decimals')::int) as base
    from token_properties
)

select tx.tx_hash as "Explorer"
, tx.block_height
-- , tx.block_time
, split_part(contract_call_contract_id,'.',2) as contract_name
, contract_call_function_name as function_name
, left(sender_address,5)||'...'||right(sender_address,5) as sender_address
, status
, right(arg_id.repr,-1)::int as vault_id
, split_part(arg_ft.repr,'.',2) as coll_id
, coalesce(1e-6 * sum(sx.amount::numeric),0)
    + coalesce(sum(fx.amount::numeric / ftp.base) filter (
    where split_part(fx.asset_identifier,'::',1) = right(arg_ft.repr,-1)
    ),0) as coll_amount
, 1e-6 * sum(fx.amount::numeric) filter (
    where fx.asset_identifier like '%usda%'
    ) as usda_burned
from transactions tx
left join stx_events sx on (sx.tx_id = tx.tx_id and sx.sender = contract_call_contract_id)
left join ft_events fx on (fx.tx_id = tx.tx_id and fx.sender = contract_call_contract_id)
join function_args arg_id on (arg_id.tx_id = tx.tx_id and arg_id.name = 'vault-id')
join function_args arg_ft on (arg_ft.tx_id = tx.tx_id and arg_ft.name = 'ft')
join ft_prop ftp on (right(arg_ft.repr,-1) = ftp.contract_id)
where contract_call_contract_id like 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-auction%'
group by 1,2,3,4,5,6,7,8
order by block_height desc
limit 100
