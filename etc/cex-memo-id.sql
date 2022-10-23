select sender_address
, left(encode(token_transfer_memo,'escape'),16) as memo
, sum(token_transfer_amount/1e6) as "Volume (STX)"
, count(*)
from transactions tx
where token_transfer_memo is not null
and (
encode(token_transfer_memo,'escape') ilike 'ok%' or
encode(token_transfer_memo,'escape') ilike 'binance%' or
encode(token_transfer_memo,'escape') ilike 'gate%' or
encode(token_transfer_memo,'escape') ilike 'coinbase%' or
encode(token_transfer_memo,'escape') ilike 'kucoin%' or
encode(token_transfer_memo,'escape') ilike 'upbit%' or
encode(token_transfer_memo,'escape') ilike 'digifinex%' or
encode(token_transfer_memo,'escape') ilike 'cro%' or
encode(token_transfer_memo,'escape') ilike 'coinex%' or
encode(token_transfer_memo,'escape') ilike 'btcturk%' )
group by 1, 2
having count(*) >= 3
order by "Volume (STX)" desc
limit 100
