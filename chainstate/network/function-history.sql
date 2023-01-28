SELECT block_height - block_height % 2500 as block_height
, left(contract,5)||'...'||right(split_part(contract,'.',1),5)||'.'||split_part(contract,'.',2) as contract
, fname
-- , value::text
, count(*) as calls
FROM function_history
GROUP BY 1,2,3
ORDER BY 1 desc, 2, 3
limit 100
