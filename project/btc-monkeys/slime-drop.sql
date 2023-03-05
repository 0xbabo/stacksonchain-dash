select ( block_time+'1 day' - make_interval(days => date_part('day',block_time+'1 day')::int % 15) ) :: date as "date"
-- , count(*) as events
-- , count(distinct tx_id) as txs
, count(distinct recipient) as recipients
, sum(amount)/1e6 as amount
from transactions tx
join ft_events fx using (tx_id,block_height)
where contract_call_contract_id = 'SPMWNPDCQMCXANG6BYK2TJKXA09BTSTES0VVBXVR.slime-stake-v3'
and contract_call_function_name = 'distribute'
and asset_identifier = 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token::SLIME'
group by 1
order by 1
