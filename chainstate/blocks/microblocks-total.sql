select count(*) as "Total"
, count(*) filter (where canonical) as "Canonical"
, round(1 - count(*) filter (where canonical) / count(*) :: numeric, 5) * 100 as "Non-canonical (%)"
from microblocks
