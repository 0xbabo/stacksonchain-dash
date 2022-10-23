with accounts as (
select distinct on (address) block_height, address from (
    select distinct block_height, recipient as address
    from stx_events
    -- order by 2, 1
union all
    select distinct block_height, recipient as address
    from ft_events
    -- order by 2, 1
union all
    select distinct block_height, recipient as address
    from nft_events
    -- order by 2, 1
) sub order by 2,1
)

select block_height - block_height % 1000 as block_height
, count(*)
from accounts
where block_height > 1
group by 1
