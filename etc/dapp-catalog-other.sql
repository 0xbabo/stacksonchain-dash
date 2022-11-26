with links ("Link","Name","Category") as (VALUES
    ('https://deeplake.finance/', 'Deep Lake', 'Testnet, Derivatives'),
    ('https://liquidium.fi/', 'Liquidium', 'Testnet, NFT Lending'),
    ('https://www.bitflow.finance/', 'Bitflow', 'Testnet, Stable Swap'),
    ('https://www.magic.fun/', 'Magic Bridge', 'Testnet, BTC Bridge'),
    ('https://www.sigle.io/', 'Sigle', 'Community, Publishing'),
    ('https://www.console.xyz/', 'Console', 'Community, Chat, DAO'),
    ('https://pravica.io/', 'Pravica', 'Community, Chat, DAO'),
    ('https://stackerdaos.com/', 'Stacker DAOs', 'Community, DAO')
)
select * from links
