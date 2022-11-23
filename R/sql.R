

sov_report.sql <- "
select ks.partition_date 
	, ks.report_year 
	, ks.report_month 
	, ks.key
	, ks.brand 
	, ks.country 
	, ks.vertical 
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
from exploratory.kayak_sov ks 
	left join exploratory.kayak_sov ps 
		on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 1)
	left join exploratory.client_sov cs 
		on (ks.brand = cs.brand and ks.country = cs.country and ks.vertical = cs.vertical and cs.partition_date = '2022-02-03')	
where ks.report_month = 3 and ks.brand is not null
order by ks.brand, ks.country desc, ks.vertical 
"

top_spends.sql <- "
select country||'_'||vertical as placement
	, brand 
	, avg_cpc
	, cost					--  2  =  1  =
	, searches			--  1  |  0  |
	, clicks				--  0  |  9  |              5  =
	, sov					  --  9  |  8  |              4  |
	, sov_adj_0			--  8  |  7  |        4  =  3  |
	, sov_est				--  7  |  6  |        3  |  2  |
	, sov_adj				--  6  |  5  |        2  =  1  =
	, searches_adj	--  5  |  4  |		    1	 |  0  ^
	, sov_change		--  4  |  3  |  2  *  0  ^   	
	, cpc_change		--  3  |  2  |  1  * 
	, elas					--  2  =  1  =  0  ^					
	, err_low				--  1  |  0  ^				
	, err_neg				--  0  ^						
from (
	select 
		  dense_rank() over(partition by ks.country, ks.vertical order by ks.cost_amt desc) as rn
		, ks.brand
		, ks.country 
		, ks.vertical
		, ks.avg_cpc_meas as avg_cpc
		, ks.cost_amt as cost
		, ks.search_cnt as searches
		, ks.click_cnt as clicks
		, ks.sov_meas as sov
		, ISNULL(cs.sov, 0) as sov_adj_0
		, ISNULL(ks.sov_meas * (sov_adj_0 / ps.sov_meas), ks.sov_meas / 4) as sov_est
		, '=INDIRECT(\"R[0]C[-1]\", FALSE)' as sov_adj
		, '=INDIRECT(\"R[0]C[-5]\", FALSE) / INDIRECT(\"R[0]C[-1]\",FALSE)' as searches_adj
		, case when sov_adj_0 = 0 then '=1' else  '=INDIRECT(\"R[0]C[-2]\", FALSE) / INDIRECT(\"R[0]C[-4]\",FALSE) - 1' end as sov_change
		, ISNULL(ks.avg_cpc_meas / ps.avg_cpc_meas - 1, 0) as cpc_change
		, case when cpc_change = 0 then '=1' else '=INDIRECT(\"R[0]C[-2]\",FALSE) / INDIRECT(\"R[0]C[-1]\",FALSE)' end as elas
		, '=IF(AND(INDIRECT(\"R[0]C[-1]\",FALSE) < settings!B3,INDIRECT(\"R[0]C[-1]\",FALSE) >= 0,INDIRECT(\"R[0]C[-11]\",FALSE) >= settings!B2),1,0)' as err_low
		, '=IF(AND(INDIRECT(\"R[0]C[-2]\",FALSE) < 0, INDIRECT(\"R[0]C[-12]\",FALSE) >= settings!B2),1,0)' as err_neg
	from exploratory.kayak_sov ks 
		left join exploratory.kayak_sov ps 
			on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 1)
	left join exploratory.client_sov cs 
		on (ks.brand = cs.brand and ks.country = cs.country and ks.vertical = cs.vertical and cs.partition_date = '2022-02-03')	
	where ks.report_month = 3 and ks.brand is not null
	order by ks.country, ks.vertical, ks.cost_amt desc
) 
where rn = 1
"

fin_report.sql <- "
select 
	  ks.brand 
	, ks.country 
	, ks.vertical
	, '=' || ks.click_cnt || '/ VLOOKUP(\"'||country||'_'||vertical||'\",top!A:Q,11,false)' as sov
from exploratory.kayak_sov ks 
where ks.report_month = 3 and ks.brand is not null
order by ks.country, ks.vertical, ks.cost_amt desc
"