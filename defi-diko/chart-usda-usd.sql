select 
    date_bin('12 hours', ts, date_trunc('day',ts)::timestamp) as interval,
    max(su.value * ds.price) as max_rate,
    min(su.value * ds.price) as min_rate,
    avg(su.value * ds.price) as avg_rate,
    1 as one
    from prices.dex_tokens_stx ds
    join ts.stx_usd_1h su USING(ts)
    where ds.timeframe = 'HOUR'
    and ds.token = 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.usda-token::usda'
    --and price < 1000 -- remove spurious events
    --and ts > now() - interval '1 month'
    
    group by interval
    order by interval
