select ks.placement
    , ks.partition_date as dt
    , ks.click_cnt
    , case when dt = '${start_month}' 
        then  '=VLOOKUP(\"' ||
                decode(ks.device,  '-1','ALL', ks.device  ) || '_' ||
                decode(ks.country, '-1','ALL', ks.country ) || '_' ||
                decode(ks.vertical,'-1','ALL', ks.vertical) || '\",top!A:Q,11,false)'
        else '=' || round(click_cnt / cs.sov, 0) end as searches_adj
    , '=INDIRECT(\"R[0]C[-2]\",FALSE) / INDIRECT(\"R[0]C[-1]\",FALSE)' as sov
from exploratory.market_sov ks 
	inner join (
		select top 10 country, vertical, device, brand
		from (
			select 
				  dense_rank() over(partition by ks.country, ks.vertical, ks.device order by ks.cost_amt desc) as rn
				, ks.brand
				, ks.country 
				, ks.vertical
                , ks.device
				, ks.cost_amt as cost
			from exploratory.market_sov ks 
			where ks.advertiser = '${advertiser}'
                and ks.partition_date = (cast('${start_month}' as date) - interval '1 month')
                    and ks.brand is not null
			order by ks.country, ks.vertical, ks.device, ks.cost_amt desc
		) ranked
		where rn = 1
		order by cost desc
	) tp on (
        ks.brand = tp.brand 
		    and ks.vertical = tp.vertical 
			    and ks.country = tp.country
                    and ks.device = tp.device
        )
	inner join exploratory.advertiser_sov cs 
		on (ks.brand = cs.brand 
			and ks.vertical = cs.vertical 
				and ks.country = cs.country
                    and ks.device = COALESCE(cs.device, '-1')
                        and ks.partition_date = cs.partition_date)
where ks.advertiser = '${advertiser}'
order by 1, 2