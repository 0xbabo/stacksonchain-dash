with categories (link, name, contract_like, comm_like_arr) as (VALUES
    ('https://www.tradeport.xyz/','Tradeport (Commission)','',
        ARRAY['%byz%','%tradeport%'
            ,'''SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.wasteland-apes-commission'
            ,'''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-megapont'
            ,'''SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.commission-robot-factory'
        ]),
    ('https://www.stacksart.com/','Stacks Art (Commission)','',ARRAY['%stacksart%','%stacks-art%']),
    ('https://gamma.io/','Gamma (Commission)','',ARRAY['%gamma%','%stxnft%'])
)

select cat.link as "Link", cat.name
, count(distinct contract_call_contract_id) as contracts
-- , count(distinct tx.sender_address) filter (where block_time > now() - interval '1 days') as users_1d
-- , count(distinct tx.tx_id) filter (where block_time > now() - interval '1 days') as txs_1d
, count(distinct tx.sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(distinct tx.tx_id) filter (where block_time > now() - interval '7 days') as txs_1w
, 1e-6 * sum(sx.amount) filter (where block_time > now() - interval'7 days') as "Vol,7D (STX)"
, count(distinct tx.sender_address) as users_all
, count(distinct tx.tx_id) as txs_all
, 1e-6 * sum(sx.amount) as "Vol,All (STX)"
from function_args arg
join categories cat on (
    arg.repr like ANY(cat.comm_like_arr)
)
left join transactions tx using (tx_id)
left join stx_events sx using (tx_id)
where arg.type = 'trait_reference'
and arg.name like 'comm%'
group by 1,2
order by users_1w desc, users_all desc
limit 100
