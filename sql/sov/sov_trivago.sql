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
with country_map as (
	select 'Algeria' as from_name, 	'AA' as to_name union all
	select 'Bahrain', 				'AA' union all
	select 'Comoros' , 				'AA' union all
	select 'Djibouti' , 			'AA' union all
	select 'Egypt' , 				'AA' union all
	select 'Iraq' , 				'AA' union all
	select 'Jordan' , 				'AA' union all
	select 'Kuwait' , 				'AA' union all
	select 'Lebanon' , 				'AA' union all
	select 'Libya' , 				'AA' union all
	select 'Mauritania' , 			'AA' union all
	select 'Morocco' , 				'AA' union all
	select 'Oman' , 				'AA' union all
	select 'Qatar' , 				'AA' union all
	select 'Saudi Arabia' , 		'AA' union all
	select 'Somalia' ,				'AA' union all
	select 'Sudan' , 				'AA' union all
	select 'Syria' , 				'AA' union all
	select 'Tunisia' , 				'AA' union all
	select 'Yemen' , 				'AA' union all
	select 'Hashemite Kingdom of Jordan' , 'AA' 		union all
	select 'Czechia' , 				'Czech Republic' 	union all
	select 'Republic of Korea' , 	'South Korea'		union all
	select 'Réunion' ,	 			'Reunion'
),
ct_clicks as (
	select
		  cast(date_trunc('month', date) as date) as month
		, advertiser_name
		, coalesce(to_name, user_country_id_name) as user_country_id_name
		, campaign_targeting_type_name
		, count(1) as total_clicks
		, sum(advertiser_cpc) as total_cost
	from v_all_clean_clicks left join country_map on user_country_id_name = from_name  
	where date between '${start_month}' and date '${start_month}' + interval '1 month'
		and advertiser_id in (156)
			and publisher_name not ilike '%parallax%'
	group by 1, 2, 3, 4
),
ct_searches as (
	select
		  cast(date_trunc('month', date) as date) as month
		, coalesce(to_name, user_country_id_name) as user_country_id_name
		, campaign_targeting_type_name
		, count(1) as total_searches
	from v_all_searches left join country_map on user_country_id_name = from_name 
	where date between '${start_month}' and date '${start_month}' + interval '1 month'
			and publisher_name not ilike '%parallax%'
	group by 1, 2, 3
)
select 'Trivago Global' as brand
	, brand ||'_'||s.user_country_id_name||'_'||s.campaign_targeting_type_name as placement
	, s.user_country_id_name as country
	, s.campaign_targeting_type_name as vertical
    , '-1' as device
	, isnull(sum(total_cost), 0) as cost_amt
	, isnull(sum(total_clicks), 0) as click_cnt
	, isnull(cost_amt / nullif(click_cnt, 0), 0) as avg_cpc_meas
	, isnull(sum(total_searches), 0) as search_cnt
	, isnull(click_cnt / cast(nullif(search_cnt,0) as numeric), 0) as sov_meas
from ct_searches s 
		left join ct_clicks a using (month, user_country_id_name, campaign_targeting_type_name)
group by 1, 2, 3, 4, 5

