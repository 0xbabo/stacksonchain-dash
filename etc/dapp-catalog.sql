-- NOTE: Does not track indirect contract calls by third party contracts.

with categories (cat_name, contract_format, source_match, link) as (VALUES
    ('ALEX', 'SP3K8BC0PPEVCV7NZ6QSRWPQ2JE9E5B6N3PA0KBR9.%', '', 'https://www.alexgo.io/'),
    ('Stackswap', 'SP1Z92MPDQEWZXW36VX71Q25HKF5K2EPCJ304F275.%', '', 'https://stackswap.org/'), -- TODO: exclude stackswap-oracle-%
    ('Arkadiko', 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.%', '', 'https://arkadiko.finance/'), -- TODO: exclude arkadiko-oracle-%
    ('NeoSwap', 'SP3Z3KVR3T0F255SC8170SZY7YB52YPY9H9TNZ9PM.%', '', 'https://neoswap.party/'),
    ('Lydian', 'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.%', '', 'https://www.lydian.xyz/'),
    ('LNSwap', 'SP2507VNQZC9VBXM7X7KB4SF4QJDJRSWHG4V39WPY.%swap%', '', 'https://www.lnswap.org/'),
    ('Catamaran Swaps', 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.%', '', 'https://www.catamaranswaps.org/'),
    ('Send Many', 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.send-many%', '', 'https://sendstx.com/'),
    ('Megapont', 'SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.%', '', 'https://www.megapont.com/'),
    ('Satoshibles', 'SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.%', '', 'https://satoshibles.com/'),
    ('Spaghetti Punk', 'SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.%', '', 'https://spaghettipunk.com/'),
    ('Bitfari', 'SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.%', '', 'https://bitfari.com/'),
    ('Stacks Degens', 'SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.%', '', 'https://stacksdegens.com/'),
    ('Stacksboard 0', 'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB.%', '', 'https://www.stacksboard.art/'),
    ('Stacksboard 1', 'SP1F6E7S7SEZZ2R2VHCY0BYJ2G81CCSSJ7PC4SSHP.%', '', 'https://www.stacksboard.art/'),
    ('Punks Army', 'SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.%', '', 'https://punksarmynft.club/'),
    ('Tiger Force', 'SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.%', '', 'https://tigerforce.io/'),
    ('Derupt', 'SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.%', '', 'https://derupt.io/'),
    ('Project Indigo', 'SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.%', '', 'https://www.projectindigonft.com/'),
    ('Bitcoin Monkeys 0', 'SP125J1ADVYWGWB9NQRCVGKYAG73R17ZNMV17XEJ7.%', '', 'https://bitcoinmonkeys.io/'),
    ('Bitcoin Monkeys 1', 'SPMWNPDCQMCXANG6BYK2TJKXA09BTSTES0VVBXVR.%', '', 'https://bitcoinmonkeys.io/'),
    ('Nonnish 0', 'SPVVASJ83H223TCEP8Z8SHZDFDBFXSM4EGSWCVR2.%', '', 'https://nonnish.com/'),
    ('Nonnish 1', 'SP1D3Y8A2VVD2W98VFXCG5AXRYX5PJBBEMV1YPKF1.%', '', 'https://nonnish.com/'),
    ('The Guests', '%.%guests%', '', 'https://guestsnft.com/'), -- NEEDS REVIEW
    ('Bitcoin Badgers 0', 'SP38FN88VZ97GWV0E8THXRM6Z5VMFPHFY4J1JEC5S.btc-badgers', '', 'https://www.bitcoinbadgers.art/'),
    ('Bitcoin Badgers 1', 'SP27F9EJH20K3GT6GHZG0RD08REZKY2TDMD6D9M2Z.%badgers%', '', 'https://www.bitcoinbadgers.art/'),
    ('Stacks Tiles', 'SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.%', '', 'https://www.stacks-tiles.com/'),
    ('Stacks Pops 0', 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-pops%', '', 'https://stackspops.club/'),
    ('Stacks Pops 1', 'SP277HZA8AGXV42MZKDW5B2NNN61RHQ42MTAHVNB1.stacks-pops%', '', 'https://stackspops.club/'),
    ('StacksArt', 'SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-art%', '', 'https://www.stacksart.com/'),
    ('This is Number One', 'SP3N4AJFZZYC4BK99H53XP8KDGXFGQ2PRSQP2HGT6.%', '', 'https://thisisnumberone.com/'),
    ('HeyLayer NFT', 'SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.%', '', 'https://www.heylayer.com/'),
    ('Byzantion NFT', 'SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%', '', 'https://www.tradeport.xyz/'), -- NEEDS REVIEW
    ('Byzantion Market', 'SP1BX0P4MZ5A3A5JCH0E10YNS170QFR2VQ6TT4NRH.%', '', 'https://www.tradeport.xyz/'), -- NEEDS REVIEW
    ('Gamma NFT', 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.%', '', 'https://gamma.io/'), -- NEEDS REVIEW
    ('Gamma BNS', '%.bns-%-%', 'SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.gamma-commission', 'https://gamma.io/collections/bns'),
    ('price.btc', 'SP3XYJ8XFZYF7MD86QQ5EF8HBVHHZFFQ9HM6SPJNQ.%', '', 'https://price.btc.us/'),
    ('Boom Deployer 0', 'SP1K1A1PMGW2ZJCNF46NWZWHG8TS1D23EGH1KNK60.%', '', 'https://boom.money/'),
    ('Boom Deployer 1', 'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.%', '', 'https://boom.money/'),
    ('Boom Deployer 2', 'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.%', '', 'https://boom.money/'),
    ('Boom Deployer 3', 'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE.%', '', 'https://boom.money/'),
    ('90stx Deployer 0', 'SPW4Z5DWXR1N6P83ZPGG50MD27DK5P5N85KGMV1E.%', '', 'https://90stx.xyz/'),
    ('90stx Deployer 1', 'SP2W58YQZEAC870M2MKE6QEKS1DPG0RMZZ2BGXSM4.%', '', 'https://90stx.xyz/'),
    ('90stx Deployer 2', 'SP1STYSN178Q1D9YGKX4JRR67J8ZMV93G5S134Z8N.%', '', 'https://90stx.xyz/'),
    -- ('StackerDAO', '', '', 'https://stackerdaos.com/'),
    -- ('Magic Protocol', '', '', 'https://www.magic.fun/'),
    ('Explorer Guild', 'SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.%', '', 'https://www.explorerguild.io/'),
    ('BlockSurvey', 'SP3A6FJ92AA0MS2F57DG786TFNG8J785B3F8RSQC9.%', '', 'https://blocksurvey.io/'),
    ('Xverse Pools', 'SPXVRSEH2BKSXAEJ00F1BY562P45D5ERPSKR4Q33.%', '', 'https://pool.xverse.app/'),
    ('CityCoins', '%.%coin-core%', '', 'https://minecitycoins.com/'), -- NEEDS REVIEW
    ('BNS', 'SP000000000000000000002Q6VF78.bns', '', 'https://btc.us/'),
    ('Stacking/POX', 'SP000000000000000000002Q6VF78.pox', '', 'https://stacking.club/')
)

select link as "Link"
, count(distinct sender_address) filter (where block_time > now() - interval '1 days') as users_1d
, count(distinct tx_id) filter (where block_time > now() - interval '24 hours') as txs_1d
, count(distinct sender_address) filter (where block_time > now() - interval '7 days') as users_1w
, count(distinct tx_id) filter (where block_time > now() - interval '7 days') as txs_1w
, count(distinct sender_address) as users_all
, count(distinct tx_id) as txs_all
, count(distinct contract_id) as contracts
, sum(sx.amount) filter (where sx.sender = sender_address) / 1e6 as "Total Vol (STX)"
from smart_contracts sc
join categories cat on (
    contract_id like contract_format and
    position(source_match in source_code) > 0 
    -- length(raw_tx) < max_size
)
left join transactions tx on (contract_id = contract_call_contract_id)
left join stx_events sx using (tx_id)
-- where block_time > now() - interval '1 days'
group by 1
order by users_1d desc, users_1w desc, users_all desc
limit 1000
