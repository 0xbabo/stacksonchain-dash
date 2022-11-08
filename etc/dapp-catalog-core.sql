with categories (link,name,contract_like_arr,source_match) as (VALUES
    ('https://gamma.io/collections/bns','Gamma (BNS)',ARRAY['%.bns-%-%'],'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission'),
    ('https://gamma.io/','Gamma (Market)',ARRAY[''
        ,'SP1CSHTKVHMMQJ7PRQRFYW6SB4QAW6SR3XY2F81PA.stxnft-auctions%'
        ,'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace%'
    ],''),
    ('https://www.tradeport.xyz/','Byzantion (Market)',ARRAY[''
        ,'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%wrapper%'
        ,'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%market%'
        ,'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.byzantion-market%'
    ],''),
    ('https://www.stacksart.com/','Stacks Art (Market)',ARRAY['SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-art%'],''),
    ('https://neoswap.party/','NeoSwap',ARRAY['SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM.%'],''), -- NOTE: double counts volume
    ('https://www.alexgo.io/','ALEX',ARRAY['SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%'],''),
    ('https://stackswap.org/','Stackswap',ARRAY['SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%'],''), -- TODO: exclude %-oracle-%
    ('https://arkadiko.finance/','Arkadiko',ARRAY['SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.%'],''), -- TODO: exclude %-oracle-%
    ('https://www.lydian.xyz/','Lydian',ARRAY['SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.%'],''),
    ('https://www.lnswap.org/','LNSwap',ARRAY['SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%swap%'],''),
    ('https://www.catamaranswaps.org/','Catamaran Swaps',ARRAY['SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.%'],''),
    ('https://sendstx.com/','Send Many',ARRAY['SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many%'],''),
    ('https://www.megapont.com/','Megapont',ARRAY['SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.%'],''),
    ('https://satoshibles.com/','Satoshibles',ARRAY['SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.%'],''),
    ('https://spaghettipunk.com/','Spaghetti Punk',ARRAY['SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.%'],''),
    ('https://bitfari.com/','Bitfari',ARRAY['SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.%'],''),
    ('https://stacksdegens.com/','Stacks Degens',ARRAY['SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.%'],''),
    ('https://punksarmynft.club/','Punks Army',ARRAY['SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.%'],''),
    ('https://tigerforce.io/','Tiger Force',ARRAY['SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.%'],''),
    ('https://derupt.io/','Derupt',ARRAY['SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.%'],''),
    ('https://www.projectindigonft.com/','Project Indigo',ARRAY['SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.%'],''),
    ('https://www.stacksboard.art/','Stacksboard',ARRAY[''
        ,'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB.%'
        ,'SP1F6E7S7SEZZ2R2VHCY0BYJ2G81CCSSJ7PC4SSHP.%'
    ],''),
    ('https://bitcoinmonkeys.io/','Bitcoin Monkeys',ARRAY[''
        ,'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.%'
        ,'SPMWNPDCQMCXANG6BYK2TJKXA09BTSTES0VVBXVR.%'
    ],''),
    ('https://nonnish.com/','Nonnish',ARRAY[''
        ,'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.%'
        ,'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.%'
    ],''),
    ('https://www.bitcoinbadgers.art/','Bitcoin Badgers',ARRAY[''
        ,'SP38FN88VZ97GWV0E8THXRM6Z5VMFPHFY4J1JEC5S.btc-badgers'
        ,'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.%badgers%'
    ],''),
    ('https://guestsnft.com/','The Guests',ARRAY['%guests%'],''),
    ('https://www.stacks-tiles.com/','Stacks Tiles',ARRAY['SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.%'],''),
    ('https://stackspops.club/','Stacks Pops',ARRAY['%stacks-pops%'],''),
    ('https://www.stackspunks.com/','Stacks Punks',ARRAY['SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-market'],''),
    ('https://thisisnumberone.com/','This is #1',ARRAY['SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.thisisnumberone%'],''),
    ('https://www.crashpunks.com/','Crashpunks',ARRAY['SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks%'],''),
    ('https://www.heylayer.com/','HeyLayer',ARRAY['SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.%'],''),
    ('https://price.btc.us/','price.btc.us',ARRAY['SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.%'],''),
    ('https://boom.money/boomboxes','Boomboxes',ARRAY['%.boombox-admin%','%.boomboxes-cycle-%'],''),
    ('https://boom.money/','Boom NFTs',ARRAY['SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts'],''),
    ('https://90stx.xyz/','90stx',ARRAY['%90stx%'],''),
    ('https://www.explorerguild.io/','Explorer Guild',ARRAY['SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.%'],''),
    ('https://blocksurvey.io/','BlockSurvey',ARRAY['SP3A6FJ92AA0MS2F57DG786TFNG8J785B3F8RSQC9.%'],''),
    ('https://pool.xverse.app/','Xverse Pools',ARRAY['SPXVRSEH2BKSXAEJ00F1BY562P45D5ERPSKR4Q33.%'],''),
    ('https://syvitamining.com/','Syvita Mining Guild',ARRAY['SP196Q1HN49MJTJFRW08RCRP7YSXY28VE72GQWS0P.%'],''),
    ('https://minecitycoins.com/','CityCoins',ARRAY['%miamicoin-core%','%newyorkcitycoin-core%'],''),
    ('https://btc.us/','BNS',ARRAY['SP000000000000000000002Q6VF78.bns'],''),
    ('https://stacking.club/','Stacking/POX',ARRAY['SP000000000000000000002Q6VF78.pox'],'')
)

select link as "Link", cat.name
, count(distinct sc.contract_id) as contracts
-- , count(distinct tx.sender_address) filter (where block_time > now() - interval '1 days') as users_1d
-- , count(distinct tx.tx_id) filter (where block_time > now() - interval '1 days') as txs_1d
, count(distinct tx.sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(distinct tx.tx_id) filter (where block_time > now() - interval '7 days') as txs_1w
, 1e-6 * sum(sx.amount) filter (where block_time > now() - interval '7 days') as "Vol,1W (STX)"
, count(distinct tx.sender_address) as users_all
, count(distinct tx.tx_id) as txs_all
, 1e-6 * sum(sx.amount) as "Vol,All (STX)"
from categories cat
join smart_contracts sc on (
    sc.contract_id like ANY(cat.contract_like_arr)
    and position(cat.source_match in sc.source_code) > 0
)
left join transactions tx on (
    contract_call_contract_id = sc.contract_id
    or smart_contract_contract_id = sc.contract_id
)
left join stx_events sx on (
    sx.tx_id = tx.tx_id
)
group by 1,2
order by users_1w desc, users_all desc
limit 500
