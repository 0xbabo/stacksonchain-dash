select block_height - block_height % 500 as block_height_bin
, count(*)::numeric / 500 as "avg microblocks"
from microblocks
where canonical is true
group by 1
order by 1
