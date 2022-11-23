select ks.vertical, ks.country, ks.device, ks.partition_date as dt
    , sum(ks.click_cnt) as click_count
    , case when dt = '${start_month}' 
        then  '=VLOOKUP(\"' ||
                decode(ks.device,  '-1','ALL', ks.device  ) || '_' ||
                decode(ks.country, '-1','ALL', ks.country ) || '_' ||
                decode(ks.vertical,'-1','ALL', ks.vertical) || '\",top!A:Q,11,false)'
        else '=' || round(max(NVL(ks.click_cnt / NULLIF(cs.sov,0))),0) end as searches_adj
    , '=INDIRECT(\"R[0]C[-2]\",FALSE) / INDIRECT(\"R[0]C[-1]\",FALSE)' as sov
from exploratory.market_sov ks 
	inner join (
		select top 15 country, vertical, device
		from (
			select 
				  ks.country 
				, ks.vertical
                , ks.device
				, sum(ks.cost_amt) as cost
				, dense_rank() over(partition by ks.country, ks.vertical, ks.device order by cost desc) as rn
			from exploratory.market_sov ks 
			where ks.advertiser = '${advertiser}'
                and ks.partition_date = (cast('${start_month}' as date) - interval '1 month')
                    and ks.brand is not null
            group by 1, 2, 3
			order by 1, 2, 3 desc
		) ranked
		where rn = 1
		order by cost desc
	) tp on (ks.vertical = tp.vertical and ks.country = tp.country and ks.device = tp.device)
	left join exploratory.advertiser_sov cs 
		on (ks.brand = cs.brand 
			and ks.vertical = cs.vertical 
				and ks.country = cs.country
                    and ks.device = COALESCE(cs.device, '-1')
                        and ks.partition_date = cs.partition_date)
where ks.advertiser = '${advertiser}'
group by 1, 2, 3, 4
order by 1, 2, 3, 4
