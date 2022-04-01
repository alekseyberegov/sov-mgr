select decode(device,'-1','ALL',device)||'_'||country||'_'||decode(vertical,'-1','ALL',vertical) as placement
	, brand 
	, avg_cpc
	, cost				--  2  =  1  =
	, searches			--  1  |  0  |
	, clicks			--  0  |  9  |              5  =
	, sov				--  9  |  8  |              4  |
	, sov_adj_0			--  8  |  7  |        4  =  3  |
	, sov_est			--  7  |  6  |        3  |  2  |
	, sov_adj			--  6  |  5  |        2  =  1  =
	, searches_adj	    --  5  |  4  |        1	 |  0  ^
	, sov_change		--  4  |  3  |  2  =  0  ^   	
	, cpc_change		--  3  |  2  |  1  = 
	, elas				--  2  =  1  =  0  ^					
	, err_low			--  1  |  0  ^				
	, err_neg			--  0  ^						
from (
	select 
		  dense_rank() over(partition by ks.country, ks.vertical, ks.device order by ks.cost_amt desc) as rn
		, ks.brand
		, ks.country 
		, ks.vertical
        , ks.device
		, ks.avg_cpc_meas as avg_cpc
		, ks.cost_amt as cost
		, ks.search_cnt as searches
		, ks.click_cnt as clicks
		, ks.sov_meas as sov
		, ISNULL(cs.sov, 0) as sov_adj_0
		, ISNULL(ks.sov_meas * (sov_adj_0 / NULLIF(ps.sov_meas,0)), ks.sov_meas / 4) as sov_est
		, '=INDIRECT(\"R[0]C[-1]\", FALSE)' as sov_adj
		, '=IFERROR(INDIRECT(\"R[0]C[-5]\", FALSE) / INDIRECT(\"R[0]C[-1]\",FALSE),0)' as searches_adj
		, case when sov_adj_0 = 0 then '=1' else  '=INDIRECT(\"R[0]C[-2]\", FALSE) / INDIRECT(\"R[0]C[-4]\",FALSE) - 1' end as sov_change
		, ISNULL(ks.avg_cpc_meas / NULLIF(ps.avg_cpc_meas,0) - 1, 0) as cpc_change
		, case when cpc_change = 0 then '=1' else '=INDIRECT(\"R[0]C[-2]\",FALSE) / INDIRECT(\"R[0]C[-1]\",FALSE)' end as elas
		, '=IF(AND(INDIRECT(\"R[0]C[-1]\",FALSE) < settings!B3,INDIRECT(\"R[0]C[-1]\",FALSE) >= 0,INDIRECT(\"R[0]C[-11]\",FALSE) >= settings!B2),1,0)' as err_low
		, '=IF(AND(INDIRECT(\"R[0]C[-2]\",FALSE) < 0, INDIRECT(\"R[0]C[-12]\",FALSE) >= settings!B2),1,0)' as err_neg
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
	order by ks.country, ks.vertical, ks.device, ks.cost_amt desc
) d
where rn = 1
order  by placement, brand
