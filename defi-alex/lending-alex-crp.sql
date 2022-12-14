with const as ( select
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-vault' as principal,
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-key-alex-autoalex::auto-key-alex-autoalex' as key_alex_soc,
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.key-alex-autoalex-v1::key-alex-autoalex-v1' as key_alex_tru,
    'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.collateral-rebalancing-pool-v1' as crp_contract
    -- functions: add-to-position-and-switch, swap-x-for-y, swap-y-for-x
    --   reduce-position-key, reduce-position-yield-many
    --   roll-borrow, roll-deposit-many, roll-auto
)

, tokens as (
    select contract, contract_id, power(10,(properties->>'decimals')::numeric) as factor
    from token_properties cross join const
    where contract_id in (
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex',
        'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.yield-alex-v1',
        key_alex_soc
    )
)

, txs as (
    select tx.* from const cross join transactions tx
    where status = 1 and tx_type = 'contract call'
	--and contract_call_function_name = 'swap-helper'
    and contract_call_contract_id = crp_contract
	--and sender_address = principal
	and block_time > '2022-06-21T06:00:00Z'
)

, events as (
    select block_time, asset_identifier,
        sum( fte.amount / tk.factor * (CASE
                WHEN (principal = recipient) THEN 1
                WHEN (principal = sender) THEN -1
                ELSE 0
            END)) as delta
	from const cross join txs tx
    join ft_events fte on (tx.tx_id = fte.tx_id and principal in (fte.sender, fte.recipient))
    join tokens tk on (tk.contract_id = fte.asset_identifier or
        (fte.asset_identifier = key_alex_tru and tk.contract_id = key_alex_soc))
    group by block_time, asset_identifier
)

, deltas as (
    select date_bin('12 hours', block_time, '2022-06-01') as interval,
    --select block_time as interval,
        sum( (CASE asset_identifier
                WHEN 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.age000-governance-token::alex'
                THEN delta ELSE 0 END) 
            ) * -1 as delta_alex,
        sum( (CASE asset_identifier
                WHEN 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.auto-alex::auto-alex'
                THEN delta ELSE 0 END) 
            ) * 1 as delta_auto,
        sum( (CASE asset_identifier
                WHEN 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.yield-alex-v1'
                THEN delta ELSE 0 END) 
            ) * 1 as delta_yield,
        sum( (CASE asset_identifier
                WHEN key_alex_tru
                THEN delta ELSE 0 END) 
            ) * -1 as delta_key
	from events cross join const
    group by interval
)

, running as (
    select interval,
    sum(delta_alex) over (order by interval) as net_alex,
    sum(delta_auto) over (order by interval) as net_auto
    --sum(delta_yield) over (order by interval) as yield_deposit,
    --sum(delta_key) over (order by interval) as key_net
    from deltas
)

select interval
, net_alex
, net_auto
, 100e3 * net_alex/net_auto as ratio_100k
, 100e3 * 1 as one_100k
from running
