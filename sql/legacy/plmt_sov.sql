select '2022-02-01' as partition_date 
	, ks.report_year 
	, 2 as report_month 
	, ks.key
	, ks.brand 
	, ks.country 
	, ks.vertical 
	, ks.search_cnt as searches
	, ks.click_cnt as clicks
	, ks.cost_amt as cost
	, round(ks.avg_cpc_meas,6) as avg_cpc
	, ks.sov_meas as sov
	, ps.search_cnt as searchs_0
	, ps.click_cnt as clicks_0
	, ps.cost_amt as cost_0
	, ps.sov_meas as sov_0
	, round(ps.avg_cpc_meas,6) as avg_cpc_0
	, cs.sov as sov_adj_0
	, round(ks.sov_meas * (sov_adj_0 / ps.sov_meas),6) as sov_est
from exploratory.kayak_sov ks 
	left join exploratory.kayak_sov ps 
		on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 1)
	left join exploratory.client_sov cs 
		on (ks.brand = cs.brand and ks.country = cs.country and ks.vertical = cs.vertical and cs.partition_date = '2022-02-03')	
where ks.report_month = 3 and ks.brand is not null
order by ks.brand, ks.country desc, ks.vertical