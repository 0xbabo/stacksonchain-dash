with links ("Link","Name","Category") as (VALUES
    ('https://wallet.hiro.so/', 'Hiro Wallet', 'Wallet, Extension'),
    ('https://www.xverse.app/', 'Xverse', 'Wallet, Mobile'),
    ('https://www.sigle.io/', 'Sigle', 'Community, Publishing'),
    ('https://www.console.xyz/', 'Console', 'Community, DAO, Chat'),
    ('https://pravica.io/', 'Pravica', 'Community, DAO, Chat'),
    ('https://stackerdaos.com/', 'Stacker DAOs', 'Community, DAO'),
    ('https://app.multisafe.xyz/', 'MultiSafe', 'Wallet, MultiSig'),
    ('https://liquidium.fi/', 'Liquidium', 'Testnet, NFT Lending'),
    ('https://www.zestprotocol.com/', 'Zest Protocol', 'Testnet, BTC Lending'),
    ('https://deeplake.finance/', 'Deep Lake', 'Testnet, Derivatives'),
    ('https://www.bitflow.finance/', 'Bitflow', 'Testnet, Stable Swap'),
    ('https://www.dlc.link/', 'DLC.Link', 'Testnet, BTC Integration'),
    ('https://www.magic.fun/', 'Magic Bridge', 'Testnet, BTC Bridge')
)
select * from links
