with markets (title,contract_format,function_name) as (VALUES
('price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.market','accept_bid'),
('Byzantion','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bns-marketplace-%','accept-bid'),
('Gamma','%.bns-%-v1', 'purchase-name')
)

, bns_cat as (
select bns, namespace
, '{name=0x'||encode(bns::bytea,'hex')||', namespace=0x'||encode(namespace::bytea,'hex')||'}' as value
, CASE
    WHEN bns ~ '^[a-z]+$' THEN 'letters'
    WHEN bns ~ '^[0-9]+$' THEN 'digits'
    WHEN left(bns,4) = 'xn--' THEN 'punycode'
    END as cat1
, CASE
    WHEN length(bns) = 1
        THEN 'Character Club (1 char)'
    WHEN bns ~ '^[a-z]+$' THEN CASE length(bns)
        WHEN 2 THEN 'UV Club (2L)'
        WHEN 3 THEN 'ABC Club (3L)'
        END
    WHEN bns ~ '^[0-9]+$' THEN CASE length(bns)
        WHEN 2 THEN '99 Club (2D)'
        WHEN 3 THEN '999 Club (3D)'
        WHEN 4 THEN '10k Club (4D)'
        WHEN 5 THEN '100k Club (5D)'
        END
    WHEN (bns ~ '^[a-z][0-9]{1,2}$' or bns ~ '^[0-9]{1,2}[a-z]$') THEN CASE length(bns)
        WHEN 2 THEN '520 Club (1L+1D)'
        WHEN 3 THEN '5200 Club (1L+2D)'
        END
    WHEN left(bns,4) = 'xn--' THEN CASE
        WHEN length(idn_punycode_decode(right(bns,-4))) = 1
            AND idn_punycode_decode(right(bns,-4)) ~ '[\U0001F300-\U0001F6FF\U0001F90C-\U0001F9FF]'
            THEN 'Punymoji Club (1 emoji)'
        END
    END as cat2
from stxop.bns_address
)

, supply as (
select cat2, count(*) as supply
from bns_cat
where namespace = 'btc'
group by 1
order by 2 desc
)

select cat2 as category
, supply
, sum(sx.amount)/1e6 as "Total Vol (STX)"
-- , sum(sx.amount)/1e6/count(distinct tx_id) as "Avg Sale (STX)"
, count(distinct tx_id) as trades
-- , users
from nft_events nx
join transactions tx using (tx_id)
join markets on (contract_call_contract_id like contract_format and contract_call_function_name = function_name)
join stx_events sx using (tx_id)
join bns_cat using (value)
join supply using (cat2)
where nx.asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
-- and nx.asset_event_type = 'transfer'
and nx.asset_event_type_id = 1
and namespace = 'btc'
group by 1,2
order by 3 desc, 1
