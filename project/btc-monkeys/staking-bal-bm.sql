with const as (
select 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.bm-stake-v1' as principal
    , 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas::BANANA' as ft_ban
    -- , 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token::SLIME' as ft_slm
    -- , 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-staking' as stake_bm
    -- , 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.mutant-monkeys-staking' as stake_mm
)

, balances as (
select date_bin('1 day', block_time, '2021-01-03')::date as interval
, sum( fx.amount * (CASE principal WHEN recipient THEN 1 WHEN sender THEN -1 END) )/1e6 as amount
from ft_events fx
join blocks b using (block_height)
cross join const
where principal in (sender, recipient)
group by 1
)

select interval
, sum(bal.amount) over (order by interval) as balance
from balances bal
cross join const
