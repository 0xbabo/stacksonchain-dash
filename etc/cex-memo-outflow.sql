select sender_address as address
, bal.total as "Balance (STX)"
, count(*) as xfers
, count(distinct token_transfer_recipient_address) as users
, count(distinct token_transfer_memo) - 1 as memos
, sum(token_transfer_amount)/1e6 as "Volume (STX)"
from transactions tx
join stxop.accounts bal on (account = sender_address)
-- where tx_type = 'token transfer'
where type_id = 0
group by 1,2
having count(*) >= 100 and count(distinct token_transfer_recipient_address) >= 10
order by "Volume (STX)" desc
limit 100
