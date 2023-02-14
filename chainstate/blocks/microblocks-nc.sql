select block_height - block_height % 500 as block_height_bin
, count(*) filter (where not canonical) :: numeric / 500 * 100 as "per 100 blocks"
, round(count(*) filter (where not canonical) / count(*) :: numeric * 100, 3) as "per all microblocks (%)"
from microblocks
group by 1
order by 1
