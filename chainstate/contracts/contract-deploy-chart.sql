with categories (cat_name, contract_format, source_match, max_size) as (
VALUES ('boilerplate', '%', 'define-constant sender ''SZ2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR', 1450)
, ('NFT', '%', 'define-non-fungible-token', 1e9)
, ('FT', '%', 'define-fungible-token', 1e9) -- may need to reorder?
, ('neoswap-party', 'SP3Z3%NZ9PM.neoswap-sc-%', 'define-public (confirm-and-escrow)', 1e9)
, ('gamma-bns', '%.bns-%-%', 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission', 1e9)
)

, contracts as (
select date_bin('7 days', block_time, '2021-01-03')::date as interval
, cat_name
, count(*)
from smart_contracts sc
join txs using (tx_hash)
left join categories on (
    contract_id like contract_format and
    position(source_match in source_code) > 0 and
    length(raw_tx) < max_size
)
group by 1,2
order by 1
)

select distinct interval
-- , coalesce( sum(count) filter (where true) over (order by interval), 0) as "Total"
, coalesce( sum(count) filter (where cat_name is null) over (order by interval), 0) as "Other"
, coalesce( sum(count) filter (where cat_name = 'NFT') over (order by interval), 0) as "NFT"
, coalesce( sum(count) filter (where cat_name = 'FT') over (order by interval), 0) as "FT"
, coalesce( sum(count) filter (where cat_name = 'boilerplate') over (order by interval), 0) as "boilerplate"
, coalesce( sum(count) filter (where cat_name = 'neoswap-party') over (order by interval), 0) as "neoswap"
, coalesce( sum(count) filter (where cat_name = 'gamma-bns') over (order by interval), 0) as "gamma-bns"
from contracts
order by 1
