with categories (link,name,address_arr) as (VALUES
    ('https://planbetter.org/','Planbetter',ARRAY['SP3TDKYYRTYFE32N19484838WEJ25GX40Z24GECPZ']),
    ('https://pool.xverse.app/','Xverse Pool',ARRAY['SPXVRSEH2BKSXAEJ00F1BY562P45D5ERPSKR4Q33.xverse-pool-%']),
    ('https://boom.money/boomboxes','Boomboxes',ARRAY[''
        ,'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boombox%'
        ,'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boombox%'
    ]),
    ('https://pool.friedger.de/','Friedger Pool',ARRAY[''
        ,'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60' -- 1 cycle
        ,'SP3K3ZEQVE1E914TFPFMT3A7M53MNMWZCFVQCQB0H' -- 3 cycle
        ,'SP6K6QNYFYF57K814W4SHNGG23XNYYE1B8NV0G1Y' -- 6 cycle
        ,'SP700C57YJFD5RGHK0GN46478WBAM2KG3A4MN2QJ' -- 12 cycle
        ,'SPCKCVQ6FTZJQYJ42FGE0FCJ1Y1QMTAK0P2WMGX7' -- deprecated
    ])
)

select cat.link as "Link", cat.name
-- , count(distinct sc.contract_id) as contracts
-- , count(distinct tx.sender_address) filter (where block_time > now() - interval '1 days') as users_1d
-- , count(distinct tx.tx_id) filter (where block_time > now() - interval '1 days') as txs_1d
, count(distinct tx.sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(distinct tx.tx_id) filter (where block_time > now() - interval '7 days') as txs_1w
-- , 1e-6 * sum(sx.amount) filter (where block_time > now() - interval '7 days') as "Vol,1W (STX)"
, count(distinct tx.sender_address) as users_all
, count(distinct tx.tx_id) as txs_all
-- , 1e-6 * sum(sx.amount) as "Vol,All (STX)"
from categories cat
join transactions tx on (
    contract_call_contract_id = 'SP000000000000000000002Q6VF78.pox'
    and contract_call_function_name = ANY(ARRAY['allow-contract-caller','delegate-stx'])
)
join function_args arg_del on (
    arg_del.tx_id = tx.tx_id 
    and arg_del.name = ANY(ARRAY['caller','delegate-to'])
    and right(arg_del.repr,-1) like ANY(address_arr)
)
-- left join function_args arg_amt on (
--     arg_amt.tx_id = tx.tx_id and arg_amt.name = 'amount-ustx'
-- )
group by 1,2
order by users_1w desc, users_all desc
limit 500
