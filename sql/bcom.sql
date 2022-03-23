select
	month
	,user_country_id_name
	,user_device_id_name
	,ISNULL(sum(bcom_total_cost),0) as bcom_cost
	,ISNULL(sum(bcom_total_clicks),0) as bcom_clicks
	,ISNULL(bcom_cost/nullif(bcom_clicks,0),0) as bcom_avg_cpc
	,ISNULL(sum(searches),0) as total_searches
	,ISNULL(bcom_clicks/nullif(total_searches,0)::numeric,0) as sov
	from(
		Select
		date_trunc('month', date)::date as month
		,user_country_id_name
		,user_device_id_name
		,0 as searches
		,count(1) as bcom_total_clicks
		,sum(advertiser_cpc) as bcom_total_cost
		From v_all_clean_clicks 
		where date >= '2022-01-01'
		AND date < '2022-02-01'
		AND advertiser_id = 8
		AND publisher_name not ilike '%parallax%'
		AND publisher_name not ilike '%spirit%'
		AND publisher_name not ilike '%mapquest%'
		AND publisher_name not ilike '%wetter%'
		Group by 1,2,3
		union all
		Select
		date_trunc('month', date)::date as month
		,user_country_id_name
		,user_device_id_name
		,count(1) as searches
		,0 as bcom_total_clicks
		,0 as bcom_total_cost
		From v_all_searches
		where date >= '2022-01-01'
		AND date < '2022-02-01'
		AND publisher_name not ilike '%parallax%'
		AND publisher_name not ilike '%spirit%'
		AND publisher_name not ilike '%mapquest%'
		AND publisher_name not ilike '%wetter%'
		group by 1,2,3)
	group by 1,2,3

