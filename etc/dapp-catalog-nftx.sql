-- NOTE: Does not track indirect contract calls by third party contracts.

with categories (link, name, contract_like, comm_like) as (VALUES
    ('https://www.tradeport.xyz/','Byzantion Market','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%wrapper%',''),
    ('https://www.tradeport.xyz/','Byzantion Market','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%market%',''),
    ('https://www.tradeport.xyz/','Byzantion Market','SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market%',''),
    ('https://www.tradeport.xyz/','Byzantion Market','','%byz%'),
    ('https://www.tradeport.xyz/','Byzantion Market','','''SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-commission'),
    ('https://www.tradeport.xyz/','Byzantion Market','','''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-megapont'),
    ('https://www.tradeport.xyz/','Byzantion Market','','''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-robot-factory'),
    ('https://www.stacksart.com/','Stacks Art','SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-art%',''),
    ('https://www.stacksart.com/','Stacks Art','','%stacksart%'),
    ('https://www.stacksart.com/','Stacks Art','','%stacks-art%'),
    ('https://gamma.io/','Gamma Market','SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxnft-auctions%',''),
    ('https://gamma.io/','Gamma Market','SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace%',''),
    ('https://gamma.io/','Gamma Market','','''%stxnft%'),
    ('https://gamma.io/','Gamma Market','','''%gamma%')
)

select cat.link as "Link", cat.name
-- , count(distinct sc.contract_id) as contracts
-- , count(distinct tx.sender_address) filter (where block_time > now() - interval '1 days') as users_1d
-- , count(distinct tx.tx_id) filter (where block_time > now() - interval '1 days') as txs_1d
, count(distinct tx.sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(distinct tx.tx_id) filter (where block_time > now() - interval '7 days') as txs_1w
, 1e-6 * sum(sx.amount) filter (where block_time > now() - interval'7 days') as "Vol,7D (STX)"
, count(distinct tx.sender_address) as users_all
, count(distinct tx.tx_id) as txs_all
, 1e-6 * sum(sx.amount) as "Vol,All (STX)"
from transactions tx
join categories cat on (contract_call_contract_id like contract_like)
left join function_args arg on (
    arg.tx_id = tx.tx_id
    and arg.type = 'trait_reference'
    and arg.name like 'comm%'
    and arg.repr like cat.comm_like
)
left join stx_events sx on (sx.tx_id = tx.tx_id)
where contract_call_function_name like any(array[
    'buy%','purchase%','list%','unlist%','%bid%','%offer%','change-price%','%auction'
    -- ,'mint%','claim%'
])
group by 1,2
order by users_1w desc, users_all desc
limit 100
