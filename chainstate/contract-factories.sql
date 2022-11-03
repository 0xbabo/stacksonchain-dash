with categories (cat_name, contract_like, source_match, max_size) as (VALUES
    ('neoswap-party', 'SP3Z3%NZ9PM.neoswap-sc-%', 'define-public (confirm-and-escrow)', 1e9),
    ('gamma-bns', '%.bns-%-%', 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission', 1e9),
    ('boilerplate', '%', 'define-constant sender ''SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR', 1450)
)

select cat_name as category
, count(distinct contract_id) as contracts
, round(avg(length(deploy.raw_tx)),3) ||' ± '|| round(stddev(length(deploy.raw_tx)),3) as deploy_size
, round(avg(deploy.fee_rate/1e6),3) ||' ± '|| round(stddev(deploy.fee_rate/1e6),3) as deploy_fee
, count(distinct call.sender_address) as users
, count(distinct call.tx_id) as txs
from categories cat
join smart_contracts sc on (
    contract_id like cat.contract_like
    and position(source_match in source_code) > 0
)
join txs deploy on (
    deploy.tx_hash = sc.tx_hash and length(deploy.raw_tx) < cat.max_size
)
left join transactions call on (call.contract_call_contract_id = contract_id)
group by 1
order by contracts desc
limit 1000
