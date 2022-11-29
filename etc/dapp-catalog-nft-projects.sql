with categories (link,name,contract_like_arr,source_match) as (VALUES
('https://owl.link/','Owl Link',ARRAY['SP3A6FJ92AA0MS2F57DG786TFNG8J785B3F8RSQC9.owl-link'],''),
('https://blocksurvey.io/','BlockSurvey',ARRAY['SPNWZ5V2TPWGQGVDR6T7B6RQ4XMGZ4PXTEE0VQ0S.blocksurvey'],''),
('https://bitfari.com/','Bitfari',ARRAY['SP213KNHB5QD308TEESY1ZMX1BP8EZDPG4JWD0MEA.%'],''),
('https://www.megapont.com/','Megapont',ARRAY['SP3D6PV2ACBPEKYJTCMH7HEN02KP87QSP8KTEH335.%'],''),
('https://satoshibles.com/','Satoshibles',ARRAY['SP6P4EJF0VG8V0RB3TQQKJBHDQKEF6NVRD1KZE3C.%'],''),
('https://spaghettipunk.com/','Spaghetti Punk',ARRAY['SP1C2K603TGWJGKPT2Z3WWHA0ARM66D352385TTWH.%'],''),
('https://stacksdegens.com/','Stacks Degens',ARRAY['SP1SCEXE6PMGPAC6B4N5P2MDKX8V4GF9QDE1FNNGJ.%'],''),
('https://punksarmynft.club/','Punks Army',ARRAY['SP2A665S3H6FVMZSY4VJ17ESXX21CGS0A32984B1H.%'],''),
('https://tigerforce.io/','Tiger Force',ARRAY['SP2P6KSAJ4JVV8PFSNKJ9BNG5PEPR4RT71VXZHWBK.%'],''),
('https://derupt.io/','Derupt',ARRAY['SP3T3JC6V4S94PPB7WFEK17863HPG3EYP6CJ65E7M.%'],''),
('https://stacksparrots.com/','Stacks Parrots',ARRAY['SP2KAF9RF86PVX3NEE27DFV1CQX0T4WGR41X3S45C.%stacks-parrots%'],''),
('https://www.projectindigonft.com/','Project Indigo',ARRAY['SP176ZMV706NZGDDX8VSQRGMB7QN33BBDVZ6BMNHD.%'],''),
('https://guestsnft.com/','The Guests',ARRAY['%guests%'],''),
('https://www.stacks-tiles.com/','Stacks Tiles',ARRAY['SPASZ0VJQTS22YR4HCCAGR05GGRF9V8TCM219YQ8.%'],''),
('https://stackspops.club/','Stacks Pops',ARRAY['%stacks-pops%'],''),
('https://www.stackspunks.com/','Stacks Punks',ARRAY['SPJW1XE278YMCEYMXB8ZFGJMH8ZVAAEDP2S2PJYG.stacks-punks-market'],''),
('https://thisisnumberone.com/','This is #1',ARRAY['SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.thisisnumberone%'],''),
('https://www.heylayer.com/','HeyLayer',ARRAY['SP248HH800501WYSG7Z2SS1ZWHQW1GGH85ME34NT2.%'],''),
('https://www.crashpunks.com/','Crashpunks',ARRAY['SP3QSAJQ4EA8WXEDSRRKMZZ29NH91VZ6C5X88FGZQ.crashpunks%'],''),
('https://www.explorerguild.io/','Explorer Guild',ARRAY['SP2X0TZ59D5SZ8ACQ6YMCHHNR2ZN51Z32E2CJ173.%'],''),
('https://90stx.xyz/','90stx',ARRAY['%90stx%'],''),
('https://boom.money/','Boom NFTs',ARRAY['SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boom-nfts'],''),
('https://boom.money/boomboxes','Boomboxes',ARRAY[''
    ,'SP497E7RX3233ATBS2AB9G4WTHB63X5PBSP5VGAQ.boombox%'
    ,'SP1QK1AZ24R132C0D84EEQ8Y2JDHARDR58R72E1ZW.boombox%'
    ,'SPMS4E9RQ4GCGG68R6D15PKV01TYNCBPYZG1ZMFE.boombox%'
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
('https://www.stacksboard.art/','Stacksboard',ARRAY[''
    ,'SPGAKH27HF1T170QET72C727873H911BKNMPF8YB.%'
    ,'SP1F6E7S7SEZZ2R2VHCY0BYJ2G81CCSSJ7PC4SSHP.%'
],'')
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
join transactions tx on (
    contract_call_contract_id like ANY(cat.contract_like_arr)
)
left join stx_events sx using (tx_id)
group by 1,2
order by users_1w desc, users_all desc
limit 500
