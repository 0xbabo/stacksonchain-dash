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
, round(yr.txs, 1)::text as txs_yr
, round(mo.txs, 1)::text as txs_eoy
, round((mo.txs / yr.txs - 1) * 100, 1)::text "Δtxs, eoy/yr (%)"
, round((yr.txs / lag(yr.txs) over (order by yr.ts) - 1) * 100, 1)::text as "Δtxs, yr/yr (%)"
, round(yr.users, 1)::text as users_yr
, round(mo.users, 1)::text as users_eoy
, round((mo.users / yr.users - 1) * 100, 1)::text as "Δusers, eoy/yr (%)"
, round((yr.users / lag(yr.users) over (order by yr.ts) - 1) * 100, 1)::text as "Δusers, yr/yr (%)"
from annual yr
left join monthly mo on (date_trunc('year',mo.ts) = yr.ts)
where extract('month' from mo.ts) = 12
order by 1
