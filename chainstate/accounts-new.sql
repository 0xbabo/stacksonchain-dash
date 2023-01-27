with creation as (
select distinct on (1) address, block_height, block_time from (
    select distinct recipient as address, block_height
    from stx_events
union all
    select distinct recipient as address, block_height
    from ft_events
union all
    select distinct recipient as address, block_height
    from nft_events
union all
    select distinct recipient as address, mature_block_height as block_height
    from miner_rewards
) x
join blocks using (block_height)
order by 1, block_height asc
)

select date_bin('7 days', block_time, '2021-01-03')::date as block_time
, count(*)
from creation
where block_height > 1
group by 1
