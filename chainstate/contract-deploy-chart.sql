with categories (cat_name, contract_format, source_match, max_size) as (VALUES
    ('neoswap-party', 'SP3Z3%NZ9PM.neoswap-sc-%', 'define-public (confirm-and-escrow)', 1e9),
    ('gamma-bns', '%.bns-%-%', 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission', 1e9),
    ('NFT', '%', 'define-non-fungible-token', 1e9),
    ('FT', '%', 'define-fungible-token', 1e9), -- may need to reorder?
    ('boilerplate', '%', 'define-constant sender ''SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR', 1450)
)

, contracts as (
    select (width_bucket(block_height, 1, get_max_block()+1, 100)-1)*get_max_block()/100+1 as block_height
    , cat_name
    , count(*) as txs
    from smart_contracts sc
    join txs using (tx_hash, block_height)
    left join categories on (
        contract_id like contract_format and
        position(source_match in source_code) > 0 and
        length(raw_tx) < max_size
    )
    group by 1,2
    order by 1
)

select distinct on (block_height) block_height
, sum(txs) filter (where cat_name is null) over (order by block_height) as "other"
, sum(txs) filter (where cat_name = 'NFT') over (order by block_height) as "NFT"
, sum(txs) filter (where cat_name = 'FT') over (order by block_height) as "FT"
, sum(txs) filter (where cat_name = 'boilerplate') over (order by block_height) as "boilerplate"
, sum(txs) filter (where cat_name = 'neoswap-party') over (order by block_height) as "neoswap"
, sum(txs) filter (where cat_name = 'gamma-bns') over (order by block_height) as "gamma-bns"
from contracts
order by 1
