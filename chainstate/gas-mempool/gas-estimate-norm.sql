-- Normalized tx fee estimated by percentiles of mempool txs received within 24 hours but before last block.
-- Minimum is determined by the bare network fee rate (1uSTX/b) times the tx size (180b for simple xfer or BNS call)

select ROUND(GREATEST(180*1e-6,PERCENTILE_CONT(0.05) within group (order by fee_rate/1e6*180/pg_column_size(payload)))::numeric,4)::text as "Casual"
     , ROUND(GREATEST(180*1e-6,PERCENTILE_CONT(0.50) within group (order by fee_rate/1e6*180/pg_column_size(payload)))::numeric,4)::text as "Standard"
     , ROUND(GREATEST(180*1e-6,PERCENTILE_CONT(0.90) within group (order by fee_rate/1e6*180/pg_column_size(payload)))::numeric,4)::text as "Rush"
from mempool cross join last_block b0
where receipt_time < b0.block_time
and receipt_time > b0.block_time - interval '24 hours'
