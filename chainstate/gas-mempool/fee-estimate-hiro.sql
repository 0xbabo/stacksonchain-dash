-- https://www.hiro.so/blog/improved-fee-estimations-in-the-hiro-wallet-and-stacks-api
-- Fee estimates for STX transfers (180 bytes) via the method used by Stacks/Hiro API.
-- Hiro wallet uses these values but with an artificial lower bound at 0.003 or 0.0025.

select to_char(PERCENTILE_CONT(0.05) within group (order by fee_rate/length(raw_tx)) * 180/1e6,'990D999999') as "Low"
     , to_char(PERCENTILE_CONT(0.50) within group (order by fee_rate/length(raw_tx)) * 180/1e6,'990D999999') as "Standard"
     , to_char(PERCENTILE_CONT(0.95) within group (order by fee_rate/length(raw_tx)) * 180/1e6,'990D999999') as "High"
from txs
where block_height > get_max_block() - 5
