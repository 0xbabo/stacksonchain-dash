with const as (
select now()::timestamp as ts_snapshot
, ARRAY['%.%'] as contract_exclude_arr
)

SELECT nx.recipient as "address",
COUNT(distinct nx.value) AS "count"
FROM transactions tx
JOIN nft_events nx ON (nx.tx_id = tx.tx_id)
cross join const
WHERE NOT exists (
    SELECT 1 FROM transactions tx_adv
    JOIN nft_events nx_adv ON (nx_adv.tx_id = tx_adv.tx_id)
    WHERE tx_adv.id > tx.id
    AND tx_adv.block_time < ts_snapshot::timestamp
    AND nx.value = nx_adv.value
    AND nx_adv.asset_identifier = nx.asset_identifier
    AND NOT nx_adv.recipient LIKE ANY(contract_exclude_arr)
)
AND asset_identifier LIKE (
'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.the-guests::%'
)
AND NOT nx.recipient LIKE ANY(contract_exclude_arr)
and tx.block_time < ts_snapshot::timestamp
GROUP BY 1
ORDER BY 2 desc, 1
limit 100
