with tokens as (
    select contract_id,
        (properties ->> 'name') name,
        (properties ->> 'symbol') symbol,
        (properties ->> 'decimals') :: numeric decimals,
        power(10, (properties ->> 'decimals') :: numeric) base
    from token_properties
    where contract in (
        'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.tokensoft-token-v4ktqebauw9', -- zero
        'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.fari-token-mn',
        'SP3NE50GEXFG9SZGTT51P40X2CKYSZ5CC4ZTZ7A2G.welshcorgicoin-token',
        -- 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1.stacks-pops-ice-v1',
        'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1.stacks-pops-ice-v2',
        'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.forcecoin',
        'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.romatoken',
        'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.btc-monkeys-bananas',
        'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.slime-token',
        'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.mega',
        'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.spaghetti'
        -- TOX (Project Indigo - off chain?)
        -- Pogs (The Guests - off chain?)
    )
), token_flow as (
    select account, asset_identifier, sum(delta) as balance from (
        select recipient as account, asset_identifier, sum(amount) as delta
        from ft_events
        join tokens on (asset_identifier = contract_id)
        group by 1, 2
    union all
        select sender as account, asset_identifier, -sum(amount) as delta
        from ft_events
        join tokens on (asset_identifier = contract_id)
        group by 1, 2
    ) sub
    group by 1, 2
), token_supply as (
    select asset_identifier as contract_id,
        split_part(asset_identifier,'.',2) as contract_name,
        sum(balance) as supply,
        count(*) as users
    from token_flow
    where account is not null
    group by 1
)
select
    name, symbol, contract_name,
    decimals, users,
    CASE WHEN base is null THEN supply::varchar
        ELSE to_char( supply / base, 'fm999G999G999G999G999G999D999')
        END as "Circulating Supply",
    split_part(contract_id,'::',1) as "Explorer"
from tokens
join token_supply using (contract_id)
order by users desc nulls last
