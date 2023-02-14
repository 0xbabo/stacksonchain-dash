select ts, value
from ts.mempool_tx
where ts > now() - interval '10 hours'
order by ts
