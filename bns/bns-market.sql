with listings as (
    select distinct on (address) address
    , tx.block_height
    , tx.block_time
    , tx.id
    , bns as name
    , namespace
    , CASE WHEN arg_price.repr is not null THEN right(arg_price.repr,-1)
        ELSE split_part(split_part(right(source_code, 150),' u',2),' ''',1)
        END :: numeric / 1e6 * 1.035 as price
    from stxop.bns_address op
    left join smart_contracts sc using (tx_hash)
    left join transactions tx on ( status = 1 and (
        sc.contract_id = tx.smart_contract_contract_id or sc.contract_id = tx.contract_call_contract_id
    ))
    left join function_args arg_price on (
        arg_price.tx_id = tx.tx_id and name = 'new-price'
    )
    where address like '%.bns-%-%'
    and position('SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission-3-5' in right(source_code,100)) > 0
    and namespace in ('btc','stx','id','app')
    and bns ^@ 'xn--'
    and idn_punycode_decode(right(bns,-4)) ~ '^[\x1F300-\x1F6FF\x1F90C-\x1F9FF\x2600-\x26FF]$'
    and not exists (
        select 1 from transactions ty
        where ty.contract_call_contract_id = sc.contract_id
        and ty.contract_call_function_name = 'unlist-name'
    )
    order by address, tx.id desc
)

select address as "Explorer"
, block_height
, block_time
, price as "Price (STX)"
, name||'.'||namespace as bns_fqn
, CASE WHEN name ^@ 'xn--'
    THEN idn_punycode_decode(right(name,-4)) ||'.'|| namespace
    END as depunycode
, 'https://gamma.io/collections/bns/' || name || '.' || namespace as "Link"
from listings
order by price
limit 100
