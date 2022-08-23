select 
    date_bin('6 hours', ts, date_trunc('day',ts)::timestamp) as interval,
    max(price) as max_rate,
    min(price) as min_rate,
    avg(price) as avg_rate
    from prices.dex_tokens_stx
    where timeframe = 'HOUR'
    and token = 'SP3MBWGMCVC9KZ5DTAYFMG1D0AEJCR7NENTM3FTK5.wrapped-lydian-token::wrapped-lydian'
    and price < 1000 -- remove spurious events
    --and ts > now() - interval '1 month'

    group by interval
    order by interval
