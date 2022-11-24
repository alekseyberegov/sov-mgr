

sov_report.sql <- "
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
	, ISNULL(ks.sov_meas * (sov_adj_0 / NULLIF(ps.sov_meas, 0)), 0) as sov_est
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
"

top_spends.sql <- "
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
"

fin_report.sql <- "
select 
	  ks.brand
	, ks.country
	, decode(ks.vertical,'-1','ALL',vertical)
    , decode(ks.device,  '-1','ALL',device)
	, '=IFERROR(' || ks.click_cnt || '/ VLOOKUP(\"'||decode(device,'-1','ALL',device)||'_'||country||'_'||decode(vertical,'-1','ALL',vertical)||'\",top!A:Q,11,false), 0)' as sov
from exploratory.market_sov ks 
where ks.partition_date = '${start_month}' 
            and ks.advertiser = '${advertiser}'
                and ks.brand is not null
order by ks.country, ks.vertical, ks.device, ks.cost_amt desc
"

hst_report.sql <- "
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
"
tgt_report.sql <- "
select advertiser_name as brand
	, model
	, market
	, decode(vertical, '-1', 'ALL', vertical) as vertical
	, decode(device,   '-1', 'ALL', device  ) as device
	, listagg(start_date::date||'; '||target::numeric(5,2), '; ') 
		WITHIN GROUP (ORDER BY start_date) as target_updates
from (
	select 
		 max(case when start_date < (cast('${start_month}' as date) - interval '1 month') then start_date end) 
			over(partition by model, market, vertical, device) as dt
		, *
	from mart.cpa_targets ct 
	where start_date < (cast('${start_month}' as date) + interval '1 month')
		and advertiser_id in ( ${advertiser_brands})
	order by model, market, vertical, device
)
where start_date >= dt
group by 1, 2, 3, 4, 5
order by 1, 2, 3, 4, 5
"
