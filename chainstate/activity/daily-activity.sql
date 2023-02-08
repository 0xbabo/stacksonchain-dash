with const as (
select '2023-01-01'::timestamp as ts_end
, '2021-01-03'::timestamp as ts_begin
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
)

, daily_running as (
select ts
, avg(txs) over (order by ts rows between 6 preceding and current row) as txs
, avg(users) over (order by ts rows between 6 preceding and current row) as users
from daily
)

select date_bin('2 days', ts, '2021-01-03')::date as ts
, avg(txs) as txs
, avg(users) as users
, null as " "
, GREATEST(0, 5e3 * ( -1.3 + log(avg(txs)) )) as "Lerp Log txs"
, GREATEST(0, 5e3 * ( -1.3 + log(avg(users)) )) as "Lerp Log users"
from daily_running
group by 1
