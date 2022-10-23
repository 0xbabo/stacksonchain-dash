with markets (title,contract_format,function_name) as (VALUES
    ('price.btc.us','SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.market','accept_bid'),
    ('Byzantion','SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.bns-marketplace-%','accept-bid'),
    ('Gamma','%.bns-%-v1', 'purchase-name')
)

, categorized as (
    select '520 Club (1L+1D)' as category
    , bns as name, namespace
    from stxop.bns_address
    where length(bns) = 2 and (bns ~ '^[0-9][a-z]$' or bns ~ '^[a-z][0-9]$')
union all
    select 'Character Club (1ch)' as category
    , bns as name, namespace
    from stxop.bns_address
    where length(bns) = 1
union all
    select 'UV Club (2L)' as category
    , bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[a-z]+$' and length(bns) = 2
union all
    select 'ABC Club (3L)' as category
    , bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[a-z]+$' and length(bns) = 3
union all
    select '99 Club (2D)' as category
    , bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[0-9]+$' and length(bns) = 2
union all
    select '999 Club (3D)' as category
    , bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[0-9]+$' and length(bns) = 3
union all
    select '10k Club (4D)' as category
    , bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[0-9]+$' and length(bns) = 4
union all
    select '100k Club (5D)' as category
    , bns as name, namespace
    from stxop.bns_address
    where bns ~ '^[0-9]+$' and length(bns) = 5
union all
    select 'Book Club (Common Words)' as category
    , bns as name, namespace
    from stxop.bns_address
    where bns in (select word from stxop.popular_words)
union all
    select 'Punymoji (1E)' as category
    , bns as name, namespace
    from stxop.bns_address
    where left(bns,4) = 'xn--'
    and length(public.idn_punycode_decode(right(bns,-4))) = 1
    and public.idn_punycode_decode(right(bns,-4)) ~ '[\U0001F300-\U0001F6FF\U0001F90C-\U0001F9FF\U00002600-\U000026FF]'
union all
    select 'Puny 999 Arabic (1-3D)' as category
    , bns as name, namespace
    from stxop.bns_address
    where left(bns,4) = 'xn--'
    and length(public.idn_punycode_decode(right(bns,-4))) <= 3
    and public.idn_punycode_decode(right(bns,-4)) ~ '^[\U00000660-\U00000669]+$'
union all
    select 'Puny Gang (Punycode)' as category
    , bns as name, namespace
    from stxop.bns_address
    where left(bns,4) = 'xn--'
    -- and length(bns) > 4
union all
    select 'Pre-Seal Club (Early)' as category
    , bns as name, namespace
    from nft_events nx 
    join stxop.bns_address on (
        bns = encode(decode(right(split_part(split_part(value,',',1),'=',2),-2), 'hex'), 'escape') and
        namespace = encode(decode(right(split_part(split_part(value,'=',3),'}',1),-2), 'hex'), 'escape')
    )
    join blocks b using (block_height)
    where block_time < '2022-09-01T00:00:00Z'
)

, supply as (
    select category, count(*) as supply
    from categorized
    where namespace = 'btc'
    group by 1
    order by 2 desc
)

select category
, supply
, sum(sx.amount/1e6) as "Total Vol (STX)"
-- , sum(sx.amount/1e6)/count(distinct tx_id) as "Avg Sale (STX)"
, count(distinct tx_id) as trades
-- , users
from nft_events nx
join transactions tx using (tx_id)
join markets on (contract_call_contract_id like contract_format and contract_call_function_name = function_name)
join stx_events sx using (tx_id)
join categorized on (
    name = encode(decode(right(split_part(split_part(nx.value,',',1),'=',2),-2), 'hex'), 'escape') and
    namespace = encode(decode(right(split_part(split_part(nx.value,'=',3),'}',1),-2), 'hex'), 'escape')
)
join supply using (category)
where nx.asset_identifier = 'SP000000000000000000002Q6VF78.bns::names'
and nx.asset_event_type = 'transfer'
and namespace = 'btc'
group by 1,2
order by 3 desc, 1
