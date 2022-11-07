-- NOTE: Does not track indirect contract calls by third party contracts.

with cat_sc (link, name, contract_like, source_match) as (VALUES
    ('https://price.btc.us/','price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.%',''),
    ('https://gamma.io/collections/bns','Gamma BNS','%.bns-%-%','SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission'),
    ('https://gamma.io/','Gamma Market','SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace%',''),
    ('https://gamma.io/','Gamma Market','SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxnft-auctions%',''),
    ('https://www.tradeport.xyz/','Byzantion Market','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%wrapper%',''),
    ('https://www.tradeport.xyz/','Byzantion Market','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%market%',''),
    ('https://www.tradeport.xyz/','Byzantion Market','SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market%',''),
    ('https://www.stacksart.com/','Stacks Art','SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-art-market%',''),
    ('https://www.stackspunks.com/','Stacks Punks','SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-market',''),
    ('https://thisisnumberone.com/','This is #1','SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.thisisnumberone%',''),
    ('https://www.heylayer.com/','HeyLayer NFTs','SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.%',''),
    ('https://boom.money/','Boom NFTs','SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts',''),
    ('https://www.megapont.com/','Megapont','SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.%','')
)

, cat_comm (link, name, comm_like) as (VALUES
    ('https://www.stacksart.com/','StacksArt','%stacksart%'),
    ('https://www.stacksart.com/','StacksArt','%stacks-art%'),
    ('https://www.tradeport.xyz/','Byzantion','%byz%'),
    ('https://www.tradeport.xyz/','Byzantion','''SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-commission'),
    ('https://www.tradeport.xyz/','Byzantion','''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-megapont'),
    ('https://www.tradeport.xyz/','Byzantion','''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-robot-factory'),
    ('https://gamma.io/','Gamma','''%stxnft%'),
    ('https://gamma.io/','Gamma','''%gamma%')
)

select comm.link as "Link", comm.name
-- , count(distinct sc.contract_id) as contracts
-- , count(distinct tx.sender_address) filter (where block_time > now() - interval '1 days') as users_1d
-- , count(distinct tx.tx_id) filter (where block_time > now() - interval '1 days') as txs_1d
, count(distinct tx.sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(distinct tx.tx_id) filter (where block_time > now() - interval '7 days') as txs_1w
, 1e-6 * sum(sx.amount) filter (where block_time > now() - interval'7 days') as "Vol,7D (STX)"
, count(distinct tx.sender_address) as users_all
, count(distinct tx.tx_id) as txs_all
, 1e-6 * sum(sx.amount) as "Vol,All (STX)"
from cat_comm comm
-- join smart_contracts sc on (
--     sc.contract_id like cat.contract_like
--     and position(cat.source_match in sc.source_code) > 0
--     -- length(raw_tx) < max_size
-- )
join function_args arg on (
    arg.type = 'trait_reference'
    and arg.name like 'comm%'
    and arg.repr like comm.comm_like
)
left join transactions tx on (
    -- tx.contract_call_contract_id = sc.contract_id or
    tx.tx_id = arg.tx_id
)
left join stx_events sx on (tx.tx_id = sx.tx_id)
-- where block_time > now() - interval '1 days'
group by 1,2
order by users_1w desc, users_all desc
limit 100
