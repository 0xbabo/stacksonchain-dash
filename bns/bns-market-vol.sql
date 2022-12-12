with markets (title,contract_format,function_name) as (VALUES
    ('price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.market','accept_bid'),
    ('Byzantion','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bns-marketplace-%','accept-bid'),
    ('Gamma','%.bns-%-v1', 'purchase-name')
)

, categorized as (
    select 'digits' as category, bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[0-9]+$'
union all
    select 'letters' as category, bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[a-z]+$'
union all
    select 'punycode' as category, bns as name, namespace
    from stxop.bns_address
    where left(bns,4) = 'xn--'
union all
    select 'other' as category, bns as name, namespace
    from stxop.bns_address
    where not (bns ~ '^[0-9]+$' or bns ~ '^[a-z]+$' or left(bns,4)='xn--')
)

select date_bin('1 day', tx.block_time, '2022-01-01')::date as block_time
, sum(sx.amount/1e6) as total
, coalesce(sum(sx.amount/1e6) filter (where category = 'digits'),0) as digits
, coalesce(sum(sx.amount/1e6) filter (where category = 'letters'),0) as letters
, coalesce(sum(sx.amount/1e6) filter (where category = 'punycode'),0) as punycode
, coalesce(sum(sx.amount/1e6) filter (where category = 'other'),0) as other
from transactions tx
join stx_events sx using (tx_id)
join nft_events nx using (tx_id)
join markets on (contract_call_contract_id like contract_format and contract_call_function_name = function_name)
join categorized on (
    name = encode(decode(rtrim(split_part(split_part(nx.value,',',1),'0x',2) ,'}'), 'hex'), 'escape') and
    namespace = encode(decode(rtrim(split_part(split_part(nx.value,',',2),'0x',2) ,'}'), 'hex'), 'escape')
)
group by 1
order by 1
