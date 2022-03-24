--
--* month
--* advertiser
--* brand
--* placement
--* country
--* vertical
--* device
--* cost_amt
--* click_cnt
--* avg_cpc_meas
--* search_cnt
--* sov_meas
--
with ct_clicks as (
	select
		  cast(date_trunc('month', date) as date) as month
		, advertiser_name
		, user_country_id_name
		, '-1' as campaign_targeting_type_name
        , user_device_id_name
		, count(1) as total_clicks
		, sum(advertiser_cpc) as total_cost
	from v_all_clean_clicks  
	where date between '${start_month}' and date '${start_month}' + interval '1 month'
		and advertiser_id in (8)
            and publisher_name not ilike '%parallax%'
            and publisher_name not ilike '%spirit%'
            and publisher_name not ilike '%mapquest%'
            and publisher_name not ilike '%wetter%'
	group by 1, 2, 3, 4, 5
),
ct_searches as (
	select
		  cast(date_trunc('month', date) as date) as month
		, user_country_id_name
		, '-1' as campaign_targeting_type_name
        , user_device_id_name
		, count(1) as total_searches
	from v_all_searches
	where date between '${start_month}' and date '${start_month}' + interval '1 month'
            and publisher_name not ilike '%parallax%'
            and publisher_name not ilike '%spirit%'
            and publisher_name not ilike '%mapquest%'
            and publisher_name not ilike '%wetter%'
	group by 1, 2, 3, 4
)
select s.month
    , 'bcom' as advertiser
    , 'Booking.com' as brand
	, brand ||'_'||s.user_country_id_name||'_'||s.user_device_id_name as placement
	, s.user_country_id_name as country
	, s.campaign_targeting_type_name as vertical
    , user_device_id_name as device
	, isnull(sum(total_cost), 0) as cost_amt
	, isnull(sum(total_clicks), 0) as click_cnt
	, isnull(cost_amt / nullif(click_cnt, 0), 0) as avg_cpc_meas
	, isnull(sum(total_searches), 0) as search_cnt
	, isnull(click_cnt / cast(nullif(search_cnt,0) as numeric), 0) as sov_meas
from ct_searches s 
		left join ct_clicks a using (month, user_country_id_name, campaign_targeting_type_name, user_device_id_name)
group by 1, 2, 3, 4, 5, 6, 7

