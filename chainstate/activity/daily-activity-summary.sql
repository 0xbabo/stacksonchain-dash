with const as (
select '2023-01-01'::timestamp as ts_end
, '2021-01-01'::timestamp as ts_begin
)

, daily as (
select block_time::date as ts
, count(*) as txs
, count(distinct sender_address) as users
from transactions
cross join const
where block_time >= ts_begin
and block_time < ts_end
group by 1
order by 1
)

, monthly as (
select date_trunc('month', ts)::date as ts
, avg(txs) as txs
, avg(users) as users
from daily
group by 1
)

, annual as (
select date_trunc('year', ts)::date as ts
, avg(txs) as txs
, avg(users) as users
from daily
group by 1
)

select extract('year' from mo.ts) as year
, to_char(yr.txs, '999G999G999G999G999D9') as "E(txs), year"
, to_char(mo.txs, '999G999G999G999G999D9') as "E(txs), eoy"
, to_char((yr.txs / lag(yr.txs) over (order by yr.ts) - 1) * 100, '999G999G999D9') as "ΔE(txs), yr/yr (%)"
, to_char((mo.txs / yr.txs - 1) * 100, '999G999G999D9') "ΔE(txs), eoy/yr (%)"
, to_char(yr.users, '999G999G999G999G999D9') as "E(users), year"
, to_char(mo.users, '999G999G999G999G999D9') as "E(users), eoy"
, to_char((yr.users / lag(yr.users) over (order by yr.ts) - 1) * 100, '999G999G999D9') as "ΔE(users), yr/yr (%)"
, to_char((mo.users / yr.users - 1) * 100, '999G999G999D9') "ΔE(users), eoy/yr (%)"
from annual yr
left join monthly mo on (date_trunc('year',mo.ts) = yr.ts)
where extract('month' from mo.ts) = 12
order by 1
