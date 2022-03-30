select ks.key, ks.partition_date as dt,  click_cnt,  cs.sov, round(click_cnt / sov, 0) as searches_adj 
from exploratory.kayak_sov ks 
	inner join (
		select top 10 country, vertical, brand
		from (
			select 
				  dense_rank() over(partition by ks.country, ks.vertical order by ks.cost_amt desc) as rn
				, ks.brand
				, ks.country 
				, ks.vertical
				, ks.cost_amt as cost
			from exploratory.kayak_sov ks 
			where ks.report_month = 1 and ks.brand is not null
			order by ks.country, ks.vertical, ks.cost_amt desc
		) d
		where rn = 1
		order by cost desc
	) tp on (ks.brand = tp.brand 
		and ks.vertical = tp.vertical 
			and ks.country = tp.country)
	inner join exploratory.client_sov cs 
		on (ks.brand = cs.brand 
			and ks.vertical = cs.vertical 
				and cs.country = tp.country
					and decode(cs.partition_date,'2021-11-30', 11, '2022-02-02', 12,'2022-02-03', 1, '2022-03-03', 2) 
					  = decode(ks.partition_date,'2021-11-30', 11, '2021-12-31', 12,'2022-01-31', 1, '2022-03-01', 2) )
where ks.partition_date in ('2021-11-30', '2021-12-31', '2022-01-31', '2022-03-01')
order by 1, 2