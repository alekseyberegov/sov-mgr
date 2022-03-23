
--
-- October report
--
with advertiser_clicks as (
Select
	date_trunc('month', date)::date as month
	,advertiser_name
	,user_country_id_name
	,campaign_targeting_type_name
	,count(1) as total_clicks
	,sum(advertiser_cpc) as total_cost
From v_all_clean_clicks 
where date >= '2021-10-01'
	AND date < '2021-11-01'
	AND advertiser_id in (1,384,166,422,437,17,474)
	AND publisher_name not ilike '%parallax%'
Group by 1,2,3,4
),
ct_searches as (
Select
	date_trunc('month', date)::date as month
	,user_country_id_name
	,campaign_targeting_type_name
	,count(1) as searches
From v_all_searches
where date >= '2021-10-01'
	AND date < '2021-11-01'
	AND publisher_name not ilike '%parallax%'
group by 1,2,3
)
Select
	s.month
	,a.advertiser_name as brand
	,s.user_country_id_name
	,s.campaign_targeting_type_name
	,ISNULL(sum(total_cost),0) as kayak_brand_cost
	,ISNULL(sum(total_clicks),0) as kayak_brand_clicks
	,ISNULL(kayak_brand_cost/nullif(kayak_brand_clicks,0),0) as kayak_brand_avg_cpc
	,ISNULL(sum(searches),0) as total_searches
	,ISNULL(kayak_brand_clicks/nullif(total_searches,0)::numeric,0) as sov
from ct_searches s
LEFT JOIN advertiser_clicks a on s.month = a.month 
	and s.user_country_id_name = a.user_country_id_name 
		and s.campaign_targeting_type_name = a.campaign_targeting_type_name
group by 1,2,3,4

--
-- December report
--
with advertiser_clicks as (
	select
		date_trunc('month', date)::date as month
		,advertiser_name
		,user_country_id_name
		,campaign_targeting_type_name
		,count(1) as total_clicks
		,sum(advertiser_cpc) as total_cost
	From v_all_clean_clicks 
	where date >= '2021-12-01'
		AND date < '2022-01-01'
		AND advertiser_id in (1,384,166,422,437,17,474)
	Group by 1,2,3,4
),
ct_searches as (
	Select
		date_trunc('month', date)::date as month
		,user_country_id_name
		,campaign_targeting_type_name
		,count(1) as searches
	From v_all_searches
	where date >= '2021-12-01'
		AND date < '2022-01-01'
	group by 1,2,3
)
-- select count(1)
-- from (
-- key,brand,country,vertial,cost_amt,click_cnt,avg_cpc_meas,sov_meas,search_cnt
select
	a.advertiser_name||'_'||s.user_country_id_name||'_'||s.campaign_targeting_type_name as "key"
	,a.advertiser_name as brand
	,s.user_country_id_name as country
	,s.campaign_targeting_type_name as vertical
	,ISNULL(sum(total_cost),0) as cost_amt
	,ISNULL(sum(total_clicks),0) as click_cnt
	,ISNULL(cost_amt/nullif(clicks_cnt,0),0) as avg_cpc_meas
	,ISNULL(sum(searches),0) as search_cnt
	,ISNULL(clicks_cnt/nullif(search_cnt,0)::numeric,0) as sov_meas
from ct_searches s
	LEFT JOIN advertiser_clicks a on s.month = a.month
		and s.user_country_id_name = a.user_country_id_name
			and s.campaign_targeting_type_name = a.campaign_targeting_type_name
group by 1,2,3,4
-- )

--
-- January report
--
with advertiser_clicks as (
	select
		date_trunc('month', date)::date as month
		,advertiser_name
		,user_country_id_name
		,campaign_targeting_type_name
		,count(1) as total_clicks
		,sum(advertiser_cpc) as total_cost
	From v_all_clean_clicks 
	where date >= '2022-01-01'
		AND date < '2022-02-01'
		AND advertiser_id in (1,384,166,422,437,17,474)
	Group by 1,2,3,4
),
ct_searches as (
	Select
		date_trunc('month', date)::date as month
		,user_country_id_name
		,campaign_targeting_type_name
		,count(1) as searches
	From v_all_searches
	where date >= '2022-01-01'
		AND date < '2022-02-01'
	group by 1,2,3
)
-- select count(1)
-- from (
-- key,brand,country,vertial,cost_amt,click_cnt,avg_cpc_meas,sov_meas,search_cnt
select
	a.advertiser_name||'_'||s.user_country_id_name||'_'||s.campaign_targeting_type_name as "key"
	,a.advertiser_name as brand
	,s.user_country_id_name as country
	,s.campaign_targeting_type_name as vertical
	,ISNULL(sum(total_cost),0) as cost_amt
	,ISNULL(sum(total_clicks),0) as click_cnt
	,ISNULL(cost_amt/nullif(clicks_cnt,0),0) as avg_cpc_meas
	,ISNULL(sum(searches),0) as search_cnt
	,ISNULL(clicks_cnt/nullif(search_cnt,0)::numeric,0) as sov_meas
from ct_searches s
	LEFT JOIN advertiser_clicks a on s.month = a.month
		and s.user_country_id_name = a.user_country_id_name
			and s.campaign_targeting_type_name = a.campaign_targeting_type_name
group by 1,2,3,4
-- )



select 'searches' as ds, min(date) as min_date
from v_all_searches vas 
where date > current_date - 90
union all
select 'clicks' as ds, min(date) as min_date
from v_all_clean_clicks vas 
where date > current_date - 90

--  -----------+------------+---------+-------------+
--  report_year|report_month|total_cnt|zero_cost_cnt|
--  -----------+------------+---------+-------------+
--         2021|          10|     2881|            0|
--         2021|          11|     3040|            0|
-- -------------------------------------------------+     
--
-- Simple checksum for reports
--
--	, search_cnt 
--	, click_cnt 
--	, cost_amt 
--	, avg_cpc_meas 
--	, sov_meas 
select partition_date, report_year, report_month 
	, count(1) as total_cnt
	, sum(case when cost_amt     is null then 1 else 0 end) as zero_cost_cnt
	, sum(case when click_cnt    is null then 1 else 0 end) as zero_click_cnt
	, sum(case when search_cnt   is null then 1 else 0 end) as zero_search_cnt
	, sum(case when avg_cpc_meas is null then 1 else 0 end) as zero_cpc_cnt
	, sum(case when sov_meas     is null then 1 else 0 end) as zero_sov_cnt
from exploratory.kayak_sov
group by 1, 2, 3
order by 1, 2, 3


select report_year, report_month, partition_date 
	, count(1) as total_cnt
from exploratory.client_sov cs 
group by 1, 2, 3
order by 1, 2, 3

select *
from exploratory.client_sov 
where brand = '' or brand is null

--report_year|report_month|partition_date|total_cnt|
-------------+------------+--------------+---------+
--       2021|          11|    2021-11-30|     2993|
--       2022|           2|    2022-02-02|     2795|
--       2022|           2|    2022-02-03|     2813|
--
--partition_date|report_year|report_month|
----------------+-----------+------------+
--    2021-10-31|       2021|          10|
--    2021-11-30|       2021|          11|
--    2021-12-31|       2021|          12|
--    2022-01-31|       2022|           1|

select partition_date 
	, report_year 
	, report_month 
	, "key" 
	, brand 
	, country 
	, vertical 
	, search_cnt 
	, click_cnt 
	, cost_amt 
	, avg_cpc_meas 
	, sov_meas 
	, sov_meas / 4 as sov_adj_meas
from exploratory.kayak_sov ks 
where report_month = 10
order by brand, country desc, vertical 

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
	, ps.sov_meas / 4 as sov_adj_0
	, ks.sov_meas * (sov_adj_0 / ps.sov_meas) as sov_est
from exploratory.kayak_sov ks 
	left join exploratory.kayak_sov ps 
		on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 10)
where ks.report_month = 11 and ks.brand is not null
order by ks.brand, ks.country desc, ks.vertical 


select country||'_'||vertical as placement
	, brand 
	, cost					--  2  =  1  =
	, searches				--  1  |  0  |
	, clicks				--  0  |  9  |              5  =
	, sov					--  9  |  8  |              4  |
	, sov_adj_0				--  8  |  7  |        4  =  3  |
	, sov_est				--  7  |  6  |        3  |  2  |
	, sov_adj				--  6  |  5  |        2  =  1  =
	, searches_adj			--  5  |  4  |		  1	 |  0  ^
	, sov_change			--  4  |  3  |  2  *  0  ^   	
	, cpc_change			--  3  |  2  |  1  * 
	, elas					--  2  =  1  =  0  ^					
	, err_low				--  1  |  0  ^				
	, err_neg				--  0  ^						
from (
	select 
		  dense_rank() over(partition by ks.country, ks.vertical order by ks.cost_amt desc) as rn
		, ks.brand
		, ks.country 
		, ks.vertical
		, ks.cost_amt as cost
		, ks.search_cnt as searches
		, ks.click_cnt as clicks
		, ks.sov_meas as sov
		, ISNULL(ps.sov_meas / 4, 0) as sov_adj_0
		, ISNULL(ks.sov_meas * (sov_adj_0 / ps.sov_meas), ks.sov_meas / 4) as sov_est
		, '=INDIRECT("R[0]C[-1]", FALSE)' as sov_adj
		, '=INDIRECT("R[0]C[-5]", FALSE) / INDIRECT("R[0]C[-1]",FALSE)' as searches_adj
		, case when sov_adj_0 = 0 then '=1' else  '=INDIRECT("R[0]C[-2]", FALSE) / INDIRECT("R[0]C[-4]",FALSE) - 1' end as sov_change
		, ISNULL(ks.avg_cpc_meas / ps.avg_cpc_meas - 1, 0) as cpc_change
		, case when cpc_change = 0 then '=1' else '=INDIRECT("R[0]C[-2]",FALSE) / INDIRECT("R[0]C[-1]",FALSE)' end as elas
		, '=IF(AND(INDIRECT("R[0]C[-1]",FALSE) < settings!B3,INDIRECT("R[0]C[-1]",FALSE) >= 0,INDIRECT("R[0]C[-11]",FALSE) >= settings!B2),1,0)' as err_low
		, '=IF(AND(INDIRECT("R[0]C[-2]",FALSE) < 0, INDIRECT("R[0]C[-12]",FALSE) >= settings!B2),1,0)' as err_neg
	from exploratory.kayak_sov ks 
		left join exploratory.kayak_sov ps 
			on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 10)
	where ks.report_month = 11 and ks.brand is not null
	order by ks.country, ks.vertical, ks.cost_amt desc
) 
where rn = 1

select 
	  ks.brand 
	, ks.country 
	, ks.vertical
	, '=' || ks.click_cnt || '/ VLOOKUP("'||country||'_'||vertical||'",top!A:Q,10,false)' as sov
from exploratory.kayak_sov ks 
where ks.report_month = 11 and ks.brand is not null
order by ks.country, ks.vertical, ks.cost_amt desc

select *
from exploratory.kayak_sov ks
where report_month = 11
order by country, vertical, brand



-- ===================================================================================

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
		on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 11)
	left join exploratory.client_sov cs 
		on (ks.brand = cs.brand and ks.country = cs.country and ks.vertical = cs.vertical and cs.report_month = 11)	
where ks.report_month = 12 and ks.brand is not null
order by ks.brand, ks.country desc, ks.vertical 


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
			on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 11)
	left join exploratory.client_sov cs 
		on (ks.brand = cs.brand and ks.country = cs.country and ks.vertical = cs.vertical and cs.report_month = 11)	
	where ks.report_month = 12 and ks.brand is not null
	order by ks.country, ks.vertical, ks.cost_amt desc
) 
where rn = 1

select partition_date, report_year, report_month , count(1)
from exploratory.client_sov cs 
group by 1, 2, 3

select *
from exploratory.client_sov cs 
where country = 'Afghanistan' and brand = 'KAYAK' and report_month = 2


-- ===================================== 2022-02-28 ==========================================
--
-- ===========================================================================================
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
			on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 12)
	left join exploratory.client_sov cs 
		on (ks.brand = cs.brand and ks.country = cs.country and ks.vertical = cs.vertical and cs.partition_date = '2022-02-03')	
	where ks.report_month = 1 and ks.brand is not null
	order by ks.country, ks.vertical, ks.cost_amt desc
) 
where rn = 1




SET partition_date = UNIX_EPOCH_TO_DATE(time);
SET report_month = MONTH(partition_date);
SET report_year = YEAR(partition_date);
// GENERATED @ 2022-02-01T00:18:13.035144Z
SELECT PARTITION_TIME(partition_date) AS partition_date,
       time AS processing_time:TIMESTAMP,
       report_year AS report_year:BIGINT,
       report_month AS report_month:BIGINT,
       data.key AS key,
       data.brand AS brand,
       data.country AS country,
       data.vertical AS vertical,
       data.search_cnt AS search_cnt:BIGINT,
       data.click_cnt AS click_cnt:BIGINT,
       data.cost_amt AS cost_amt:DOUBLE,
       data.avg_cpc_meas AS avg_cpc_meas:DOUBLE,
       data.sov_meas AS sov_meas:DOUBLE
  FROM "s3_kayak_sov"  

  
  
  
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
		on (ks.brand = ps.brand and ks.country = ps.country and ks.vertical = ps.vertical and ps.report_month = 12)
	left join exploratory.client_sov cs 
		on (ks.brand = cs.brand and ks.country = cs.country and ks.vertical = cs.vertical and cs.report_month = 2)	
where ks.report_month = 1 and ks.brand is not null
order by ks.brand, ks.country desc, ks.vertical

---
--- implied searches volitility
---
--report_year|report_month|partition_date|total_cnt|
-------------+------------+--------------+---------+
--       2021|          11|    2021-11-30|     2993|
--       2022|           2|    2022-02-02|     2795|
--       2022|           2|    2022-02-03|     2813|
--
--partition_date|report_year|report_month|
----------------+-----------+------------+
--    2021-10-31|       2021|          10|
--    2021-11-30|       2021|          11|
--    2021-12-31|       2021|          12|
--    2022-01-31|       2022|           1|

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
		) 
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

---
----
--


--
-- February report
--
with advertiser_clicks as (
	select
		date_trunc('month', date)::date as month
		,advertiser_name
		,user_country_id_name
		,campaign_targeting_type_name
		,count(1) as total_clicks
		,sum(advertiser_cpc) as total_cost
	From v_all_clean_clicks 
	where date >= '2022-02-01'
		AND date < '2022-03-01'
		AND advertiser_id in (1,384,166,422,437,17,474)
	Group by 1,2,3,4
),
ct_searches as (
	Select
		date_trunc('month', date)::date as month
		,user_country_id_name
		,campaign_targeting_type_name
		,count(1) as searches
	From v_all_searches
	where date >= '2022-02-01'
		AND date < '2022-03-01'
	group by 1,2,3
)
-- select count(1)
-- from (
-- key,brand,country,vertial,cost_amt,click_cnt,avg_cpc_meas,sov_meas,search_cnt
select
	a.advertiser_name||'_'||s.user_country_id_name||'_'||s.campaign_targeting_type_name as "key"
	,a.advertiser_name as brand
	,s.user_country_id_name as country
	,s.campaign_targeting_type_name as vertical
	,ISNULL(sum(total_cost),0) as cost_amt
	,ISNULL(sum(total_clicks),0) as click_cnt
	,ISNULL(cost_amt/nullif(click_cnt,0),0) as avg_cpc_meas
	,ISNULL(sum(searches),0) as search_cnt
	,ISNULL(click_cnt/nullif(search_cnt,0)::numeric,0) as sov_meas
from ct_searches s
	LEFT JOIN advertiser_clicks a on s.month = a.month
		and s.user_country_id_name = a.user_country_id_name
			and s.campaign_targeting_type_name = a.campaign_targeting_type_name
group by 1,2,3,4
-- )



--partition_date|report_year|report_month|count|
----------------+-----------+------------+-----+
--    2021-10-31|       2021|          10| 2881|
--    2021-11-30|       2021|          11| 3040|
--    2021-12-31|       2021|          12| 2821|
--    2022-01-31|       2022|           1| 2848|
select partition_date, report_year, report_month , count(1)
from exploratory.kayak_sov ks 
group by 1,2,3
order by 1

select partition_date, report_year, report_month , count(1)
from exploratory.client_sov  ks 
group by 1,2,3
order by 1






-- "ct-prod-exploratory".advertiser_sov source


SELECT
  "a"."partition_date"
, "a"."upsolver_schema_version"
, "a"."vertical"
, "a"."report_year"
, "a"."report_month"
, "a"."country"
, "a"."brand"
, "a"."device"
, "a"."advertiser"
, "a"."processing_time"
, "a"."sov"
FROM
  (exploratory."advertiser_sov_underlying_table" "a"
LEFT JOIN (
   SELECT DISTINCT "upsert_key_13f2727620cd25844474e24cc52c0e45" "____key____"
   FROM
     exploratory."advertiser_sov_underlying_table"
   WHERE ("row_type_13f2727620cd25844474e24cc52c0e45" = 'update')
)  u ON ("a"."upsert_key_13f2727620cd25844474e24cc52c0e45" = "u"."____key____"))
WHERE (("row_type_13f2727620cd25844474e24cc52c0e45" = 'insert') AND ("u"."____key____" IS NULL))
UNION ALL SELECT
  "u"."partition_date"
, "u"."upsolver_schema_version"
, "u"."vertical"
, "u"."report_year"
, "u"."report_month"
, "u"."country"
, "u"."brand"
, "u"."device"
, "u"."advertiser"
, "u"."processing_time"
, "u"."sov"
FROM
  (
   SELECT
     "rank"() OVER (PARTITION BY "upsert_key_13f2727620cd25844474e24cc52c0e45" ORDER BY "processing_time_13f2727620cd25844474e24cc52c0e45" DESC, "shard_number_13f2727620cd25844474e24cc52c0e45" DESC, "key_occurrence_13f2727620cd25844474e24cc52c0e45" DESC, "upsolver_schema_version" DESC) "rn_13f2727620cd25844474e24cc52c0e45"
   , "vertical"
   , "report_year"
   , "report_month"
   , "country"
   , "brand"
   , "device"
   , "advertiser"
   , "processing_time"
   , "sov"
   , "date"("partition_date_field_13f2727620cd25844474e24cc52c0e45") "partition_date"
   , "upsolver_schema_version"
   FROM
     exploratory."advertiser_sov_underlying_table"
   WHERE ("row_type_13f2727620cd25844474e24cc52c0e45" = 'update')
)  u
WHERE ("rn_13f2727620cd25844474e24cc52c0e45" = 1);