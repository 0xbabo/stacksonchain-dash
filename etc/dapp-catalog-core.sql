with categories (link,name,contract_like_arr,source_match) as (VALUES
('https://neoswap.party/','NeoSwap',ARRAY['SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM.%'],''),
('https://liquidium.finance/','Liquidium',ARRAY['SPDRDM1JT758J434YBFGASNEVY62NYEY673443EJ.%'],''),
('https://www.alexgo.io/','ALEX',ARRAY['SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%'],''),
('https://stackswap.org/','Stackswap',ARRAY['SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%'],''),
('https://arkadiko.finance/','Arkadiko',ARRAY['SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.%'],''),
('https://www.lydian.xyz/','Lydian',ARRAY['SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.%'],''),
('https://www.lnswap.org/','LNSwap',ARRAY['SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%swap%'],''),
('https://www.catamaranswaps.org/','Catamaran Swaps',ARRAY['SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.%swap%'],''),
('https://www.mateswap.io/','Cryptomate (Defunct)',ARRAY['SP32NTG209B861QBHF4TH0C86QB0A12TY2F16WHMY.%'],''),
('https://sendstx.com/','Send Many',ARRAY['SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many%'],''),
('https://handles.ryder.id/','Ryder ID',ARRAY['SPC0KWNBJ61BDZRPF3W2GHGK3G3GKS8WZ7ND33PS.%'],''),
('https://board.stacksforce.xyz/','Stacks Force',ARRAY['SP137KE5TWH59D3N53KD5MXM4TZP2FPQD2VCTXV43.%'],''),
('https://ballot.gg/','Ballot',ARRAY['%.ballot-%'],''),
('https://syvitamining.com/','Syvita Mining Guild',ARRAY[''
    ,'SP196Q1HN49MJTJFRW08RCRP7YSXY28VE72GQWS0P.%'
    ,'SP343J7DNE122AVCSC4HEK4MF871PW470ZSXJ5K66.%'
],''),
('https://www.kcvdao.com/','KCV DAO',ARRAY[''
    ,'SP1W7X92JG1BYPKG15KTS6398XN4D4HJP9TTXMQ38.%'
    ,'SP36YQRWXTH3MHVC5GW32VFHNEF1YK30FXYXCKBDG.%'
    ,'SP12G8K8PHHYQ1P1HGW4WA2BCZ9NGB6NWW7D9H3P.%'
],''),
('https://wrapped.com/','Wrapped',ARRAY[''
    ,'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.Wrapped-%'
    ,'SP2TZK01NKDC89J6TA56SA47SDF7RTHYEQ79AAB9A.Wrapped-%'
],''),
('https://minecitycoins.com/','CityCoins',ARRAY['%miamicoin-core%','%newyorkcitycoin-core%'],''),
('https://btc.us/','BNS',ARRAY['SP000000000000000000002Q6VF78.bns'],''),
('https://stacking.club/','Stacking/POX',ARRAY['SP000000000000000000002Q6VF78.pox'],'')
)

select cat.link as "Link", cat.name as "Name"
, count(distinct contract_call_contract_id) as contracts
, count(distinct sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(*) filter (where block_time > now() - interval '7 days') as txs_1w
, 1e-6 * sum(amount) filter (where block_time > now() - interval '7 days') as "Raw Vol, 1W (STX)"
, count(distinct sender_address) as users_all
, count(*) as txs_all
, 1e-6 * sum(amount) as "Raw Vol, All (STX)"
from categories cat
left join transactions tx on (
    contract_call_contract_id like ANY(cat.contract_like_arr)
)
left join stx_events sx using (tx_id)
-- ignore oracle feeds
where contract_call_contract_id not like '%-oracle-%' -- arkadiko, stackswap
and contract_call_contract_id != 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.alex-vault'
group by 1,2
order by users_1w desc, users_all desc
limit 500
