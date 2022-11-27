with cat_cust (link,name,contract_like_arr,source_match) as (VALUES
    ('https://gamma.io/collections/bns','Gamma (BNS)',ARRAY['%.bns-%-%'],'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission'),
    ('https://gamma.io/','Gamma',ARRAY[''
        ,'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxnft-auctions%'
        ,'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace%'
    ],''),
    ('https://www.tradeport.xyz/','Tradeport',ARRAY[''
        ,'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%wrapper%'
        ,'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%market%'
        ,'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market%'
    ],''),
    ('https://www.stacksart.com/','Stacks Art',ARRAY['SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-art%'],''),
    ('https://price.btc.us/','price.btc',ARRAY['SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.%'],'')
)

, cat_nonc (link, name, contract_like, comm_like_arr) as (VALUES
    ('https://gamma.io/','Gamma','',ARRAY['%gamma%','%stxnft%']),
    ('https://www.tradeport.xyz/','Tradeport','',
        ARRAY['%byz%','%tradeport%'
            ,'''SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-commission'
            ,'''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-megapont'
            ,'''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-robot-factory'
        ]),
    ('https://www.stacksart.com/','Stacks Art','',ARRAY['%stacksart%','%stacks-art%'])
)

, events as (
    select cat.link as cat_link, cat.name as cat_name
    , tx.block_height, tx.block_time, tx.tx_id, tx.sender_address
    , sc.contract_id as contract_id
    , sum(sx.amount::numeric) as amount
    from cat_cust cat
    join smart_contracts sc on (
        sc.contract_id like ANY(cat.contract_like_arr)
        and position(cat.source_match in sc.source_code) > 0
    )
    left join transactions tx on (
        contract_call_contract_id = sc.contract_id
        or smart_contract_contract_id = sc.contract_id
    )
    left join stx_events sx on (
        sx.tx_id = tx.tx_id
    )
    group by 1,2,3,4,5,6,7

union all

    select cat.link as cat_link, cat.name as cat_name
    , tx.block_height, tx.block_time, tx.tx_id, tx.sender_address
    , tx.contract_call_contract_id as contract_id
    , sum(sx.amount::numeric) as amount
    from function_args arg
    join cat_nonc cat on (
        arg.repr like ANY(cat.comm_like_arr)
    )
    left join transactions tx using (tx_id)
    left join stx_events sx using (tx_id)
    where arg.type = 'trait_reference'
    and arg.name like 'comm%'
    group by 1,2,3,4,5,6,7
)

, contracts as (
    select cat_link, cat_name
    , count(*) as contracts
    from (
        select distinct on (cat_link,cat_name,contract_id) cat_link, cat_name, contract_id, block_time
        from events order by cat_link, cat_name, contract_id, block_time desc
    ) foo
    group by 1,2
)

, users as (
    select cat_link, cat_name
    -- , count(*) filter (where block_time > now() - interval '1 days') as users_1d
    , count(*) filter (where block_time > now() - interval '7 days') as users_1w
    , count(*) as users_all
    from (
        select distinct on (cat_link,cat_name,sender_address) cat_link, cat_name, sender_address, block_time
        from events order by cat_link, cat_name, sender_address, block_time desc
    ) foo
    group by 1,2
)

select cat_link as "Link", cat_name as "Name"
, contracts
-- , users_1d
-- , count(*) filter (where block_time > now() - interval '1 days') as txs_1d
, users_1w
, count(*) filter (where block_time > now() - interval '7 days') as txs_1w
, 1e-6 * sum(amount) filter (where block_time > now() - interval '7 days') as "Raw Vol, 1W (STX)"
, users_all
, count(*) as txs_all
, 1e-6 * sum(amount) as "Raw Vol, All (STX)"
from events ev
join contracts using (cat_link,cat_name)
join users using (cat_link,cat_name)
group by 1,2,3, users_1w, users_all
order by users_1w desc, users_all desc
limit 100
