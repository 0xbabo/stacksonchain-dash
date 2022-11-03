with known_accounts (address, description) as (VALUES
    ('SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM', 'Neoswap DAO'),
    ('SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S', 'Gamma DAO'),
    ('SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C', 'Byzantion DAO'),
    ('SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9', 'ALEX DAO'),
    ('SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275', 'Stackswap DAO'),
    ('SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR', 'Arkadiko DAO'),
    ('SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5', 'Lydian DAO'),
    ('SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ', 'price.btc.us'),
    ('SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335', 'Megapont DAO'),
    ('SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C', 'Satoshibles DAO'),
    ('SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG', 'StacksArt DAO'),
    ('SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60', 'Boom Deployer 0'),
    ('SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ', 'Boom Deployer 1'),
    ('SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW', 'Boom Deployer 2'),
    ('SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE', 'Boom Deployer 3'),
    ('SPW4Z5DWXR1N6P83ZPGG50MD27DK5P5N85KGMV1E', '90stx Deployer 0'),
    ('SP2W58YQZEAC870M2MKE6QEKS1DPG0RMZZ2BGXSM4', '90stx Deployer 1'),
    ('SP1STYSN178Q1D9YGKX4JRR67J8ZMV93G5S134Z8N', '90stx Deployer 2'),
    ('SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE', 'SendMany Deployer'),
    ('SP000000000000000000002Q6VF78', 'Null Deployer')
)

, top_each as (
    select distinct on (deployer) split_part(contract_call_contract_id,'.',1) as deployer
    , split_part(contract_call_contract_id,'.',2) as name
    , count(*)
    from transactions tx
    where not contract_call_contract_id is null
    group by 1,2
    order by deployer, count desc
    -- limit 500
)

select deployer||'.'||top.name as "Explorer"
, left(split_part(contract_id,'.',1),5)||'...'||right(split_part(contract_id,'.',1),5) as deployer
, bns||'.'||namespace as bns
, description
, top.name as top_contract
, count(distinct contract_id) as contracts
, count(distinct sender_address) as users
, count(distinct tx.tx_id) as txs
, sum(sx.amount)/1e6 as "Total Vol (STX)"
from smart_contracts sc
left join top_each top on (deployer = split_part(contract_id,'.',1))
left join stxop.bns_address bns on (bns.address = split_part(contract_id,'.',1))
left join known_accounts aka on (aka.address = split_part(contract_id,'.',1))
left join transactions tx on (contract_call_contract_id = contract_id)
-- left join stx_events sx on (sx.tx_id = tx.tx_id and sender = sender_address)
left join stx_events sx using (tx_id)
-- where contract_id not like '%.bns-%-v1'
group by 1,2,3,4,5
order by "Total Vol (STX)" desc nulls last, txs desc
limit 100
