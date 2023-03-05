select tx_hash as "Explorer"
-- , block_time::date
, block_height, microblock_sequence, tx_index
, id, tx_type
from transactions
where block_height = 85595
order by block_height desc, microblock_sequence desc, tx_index desc
-- order by id desc -- equivalent order
limit 100
