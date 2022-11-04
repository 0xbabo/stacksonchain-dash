-- NOTE: Does not track indirect contract calls by third party contracts.

with categories (link, name, contract_like, source_match) as (VALUES
    ('https://gamma.io/collections/bns','Gamma BNS', '%.bns-%-%', 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission'),
        -- does not include initial deployment txs
    ('https://neoswap.party/','NeoSwap', 'SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM.%', ''), -- NOTE: double counts volume
    ('https://www.alexgo.io/','ALEX', 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%', ''),
    ('https://stackswap.org/','Stackswap', 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%', ''), -- TODO: exclude %-oracle-%
    ('https://arkadiko.finance/','Arkadiko', 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.%', ''), -- TODO: exclude %-oracle-%
    ('https://www.lydian.xyz/','Lydian', 'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.%', ''),
    ('https://www.lnswap.org/','LNSwap', 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%swap%', ''),
    ('https://www.catamaranswaps.org/','Catamaran Swaps', 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.%', ''),
    ('https://sendstx.com/','Send Many', 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many%', ''),
    ('https://www.megapont.com/','Megapont', 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.%', ''),
    ('https://satoshibles.com/','Satoshibles', 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.%', ''),
    ('https://spaghettipunk.com/','Spaghetti Punk', 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.%', ''),
    ('https://bitfari.com/','Bitfari', 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.%', ''),
    ('https://stacksdegens.com/','Stacks Degens', 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.%', ''),
    ('https://www.stacksboard.art/','Stacksboard', 'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB.%', ''),
    ('https://www.stacksboard.art/','Stacksboard', 'SP1F6E7S7SEZZ2R2VHCY0BYJ2G81CCSSJ7PC4SSHP.%', ''),
    ('https://punksarmynft.club/','Punks Army', 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.%', ''),
    ('https://tigerforce.io/','Tiger Force', 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.%', ''),
    ('https://derupt.io/','Derupt', 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.%', ''),
    ('https://www.projectindigonft.com/','Project Indigo', 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.%', ''),
    ('https://bitcoinmonkeys.io/','Bitcoin Monkeys', 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.%', ''),
    ('https://bitcoinmonkeys.io/','Bitcoin Monkeys', 'SPMWNPDCQMCXANG6BYK2TJKXA09BTSTES0VVBXVR.%', ''),
    ('https://nonnish.com/','Nonnish', 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.%', ''),
    ('https://nonnish.com/','Nonnish', 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.%', ''),
    ('https://guestsnft.com/','The Guests', '%.%guests%', ''),
    ('https://www.bitcoinbadgers.art/','Bitcoin Badgers', 'SP38FN88VZ97GWV0E8THXRM6Z5VMFPHFY4J1JEC5S.btc-badgers', ''),
    ('https://www.bitcoinbadgers.art/','Bitcoin Badgers', 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.%badgers%', ''),
    ('https://www.stacks-tiles.com/','Stacks Tiles', 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.%', ''),
    ('https://stackspops.club/','Stacks Pops', '%.stacks-pops%', ''),
    ('https://www.stacksart.com/','StacksArt', 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.%market%', ''),
    ('https://thisisnumberone.com/','This is #1 NFTs', 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6.%', ''),
    ('https://www.heylayer.com/','HeyLayer NFTs', 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.%', ''),
    ('https://www.tradeport.xyz/','Byzantion Market', 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%market%', ''),
    ('https://www.tradeport.xyz/','Byzantion Market', 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.%market%', ''),
    ('https://gamma.io/','Gamma Market', 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.marketplace-%', ''),
    ('https://price.btc.us/','price.btc.us', 'SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.%', ''),
    ('https://boom.money/','Boomboxes', '%.boombox-admin%', ''),
    ('https://boom.money/','Boomboxes', '%.boomboxes-cycle-%', ''),
    ('https://boom.money/','Boom NFTs', 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts', ''),
    ('https://90stx.xyz/','90stx', '%.%90stx%', ''),
    -- ('https://stackerdaos.com/','StackerDAO', '', ''),
    -- ('https://www.magic.fun/','Magic Protocol', '', ''),
    ('https://www.explorerguild.io/','Explorer Guild', 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.%', ''),
    ('https://blocksurvey.io/','BlockSurvey', 'SP3A6FJ92AA0MS2F57DG786TFNG8J785B3F8RSQC9.%', ''),
    ('https://pool.xverse.app/','Xverse Pools', 'SPXVRSEH2BKSXAEJ00F1BY562P45D5ERPSKR4Q33.%', ''),
    ('https://syvitamining.com/', 'Syvita Mining Guild', 'SP196Q1HN49MJTJFRW08RCRP7YSXY28VE72GQWS0P.%', ''),
    ('https://minecitycoins.com/','CityCoins', '%.%coin-core%', ''),
    ('https://btc.us/','BNS', 'SP000000000000000000002Q6VF78.bns', ''),
    ('https://stacking.club/','Stacking/POX', 'SP000000000000000000002Q6VF78.pox', '')
)

select link as "Link", cat.name
, count(distinct sc.contract_id) as contracts
-- , count(distinct tx.sender_address) filter (where block_time > now() - interval '1 days') as users_1d
-- , count(distinct tx.tx_id) filter (where block_time > now() - interval '1 days') as txs_1d
, count(distinct tx.sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(distinct tx.tx_id) filter (where block_time > now() - interval '7 days') as txs_1w
, 1e-6 * sum(sx.amount) filter (where block_time > now() - interval '7 days') as "1W Vol (STX)"
, count(distinct tx.sender_address) as users_all
, count(distinct tx.tx_id) as txs_all
, 1e-6 * sum(sx.amount) as "Total Vol (STX)"
from categories cat
join smart_contracts sc on (
    sc.contract_id like cat.contract_like
    and position(cat.source_match in sc.source_code) > 0
    -- length(raw_tx) < max_size
)
left join transactions tx on (
    tx.contract_call_contract_id = sc.contract_id
)
left join stx_events sx on (
    sx.tx_id = tx.tx_id
    -- and sx.sender = tx.sender_address
)
-- where block_time > now() - interval '1 days'
group by 1,2
order by users_1w desc, users_all desc
limit 500
