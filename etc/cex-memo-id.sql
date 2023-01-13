with strings (str) as (
VALUES ('cro%'),('crypto%'),('cdc%')
,('kraken%'),('up%bit%'),('liquid%'),('aax%')
,('btc%turk%'),('coin%ex%'),('digi%finex%'),('dfx%')
-- ,('ok%x%'),('ok%c%'),('binance%'),('coinbase%'),('gate%'),('kucoin%')
)

select str as memo_string
, sender_address
-- , send.total as "Sender Balance (STX)"
, token_transfer_recipient_address
-- , recv.total as "Recip. Balance (STX)"
, sum(token_transfer_amount)/1e6 as "Volume (STX)"
, count(*) as txs
from transactions tx
join strings on (
lower(replace(encode(token_transfer_memo,'escape'), E'\\000', '')) like str
)
-- join stxop.accounts send on (send.account = sender_address)
-- join stxop.accounts recv on (recv.account = token_transfer_recipient_address)
where tx_type = 'token transfer'
-- and token_transfer_memo is not null
and position(b('0x00') in token_transfer_memo) != 1
group by 1,2,3
-- having sum(token_transfer_amount)/1e6 > 1e3
order by 1, txs desc
-- limit 100
