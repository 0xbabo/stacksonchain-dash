with accounts as (
select distinct on (address) block_height, block_time, address from (
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
) sub
join blocks using (block_height)
order by address, block_height
)

select date_bin('7 days', block_time, '2021-01-03')::date as block_time
, count(*)
from accounts
where block_height > 1
group by 1
