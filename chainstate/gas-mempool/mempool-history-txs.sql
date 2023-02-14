select ts, value
from ts.mempool_tx
where ts > now() - interval '1000 minutes' -- ~100 blocks
order by ts
