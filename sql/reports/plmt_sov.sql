select ks.partition_date 
	, ks.placement
	, ks.brand 
	, ks.country 
	, ks.vertical 
	, ks.device
	, ks.search_cnt as searches
	, ks.click_cnt as clicks
	, ks.cost_amt as cost
	, ks.avg_cpc_meas as avg_cpc
	, ks.sov_meas as sov
	, ps.search_cnt as searchs_0
	, ps.click_cnt as clicks_0
	, ps.cost_amt as cost_0
	, ps.sov_meas as sov_0
	, ps.avg_cpc_meas as avg_cpc_0
	, cs.sov as sov_adj_0
	, ks.sov_meas * (sov_adj_0 / ps.sov_meas) as sov_est
from exploratory.market_sov ks 
	left join exploratory.market_sov ps 
		on (ks.brand = ps.brand 
			and ks.country = ps.country 
				and ks.vertical = ps.vertical 
					and ks.device = ps.device
						and ks.advertiser = ps.advertiser
							and ps.partition_date = (cast('${start_month}' as date) - interval '1 month'))
	left join exploratory.advertiser_sov cs 
		on (ks.brand = cs.brand 
			and ks.country = cs.country 
				and ks.vertical = cs.vertical 
					and ks.device = COALESCE(cs.device, '-1')
						and ks.advertiser = cs.advertiser
							and cs.partition_date = (cast('${start_month}' as date) - interval '1 month'))
where ks.partition_date = '${start_month}' 
		and ks.advertiser = '${advertiser}'
			and ks.brand is not null
order by ks.brand
		, ks.country desc
		, ks.vertical
		, ks.device