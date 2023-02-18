with categories (link,name,address_arr) as (
VALUES ('https://planbetter.org/','Planbetter',ARRAY['SP3TDKYYRTYFE32N19484838WEJ25GX40Z24GECPZ'])
, ('https://pool.xverse.app/','Xverse Pool',ARRAY['SPXVRSEH2BKSXAEJ00F1BY562P45D5ERPSKR4Q33'])
, ('https://pool.friedger.de/','Friedger Pools',
ARRAY['SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60' -- 1 cycle
    , 'SP3K3ZEQVE1E914TFPFMT3A7M53MNMWZCFVQCQB0H' -- 3 cycle
    , 'SP6K6QNYFYF57K814W4SHNGG23XNYYE1B8NV0G1Y' -- 6 cycle
    , 'SP700C57YJFD5RGHK0GN46478WBAM2KG3A4MN2QJ' -- 12 cycle
    , 'SPCKCVQ6FTZJQYJ42FGE0FCJ1Y1QMTAK0P2WMGX7' -- deprecated
])
)

select cat.link as "Link", cat.name as "Name"
, count(distinct contract_call_contract_id) as contracts
, count(distinct sender_address) as pools
, count(distinct locked_address) as users
, count(distinct tx_id) as txs
, count(*) as lock_events
, sum(locked_amount/1e6 * (unlock_height - burn_block_height)/2100) as "Lock Vol (cycles)*(STX)"
from stx_lock_events lx
join transactions tx using (tx_id,block_height)
join blocks bx using (block_height)
join categories cat on (
    sender_address = ANY(address_arr)
)
group by 1,2
order by users desc
