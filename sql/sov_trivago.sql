select
	user_country_id_name
	,campaign_targeting_type_name
	--month 1
	,ISNULL(sum(trivago_total_cost),0) as month_cost
	,ISNULL(sum(trivago_total_clicks),0) as month_clicks
	,ISNULL(month_cost/nullif(month_clicks,0),0) as month_cpc
	,ISNULL(sum(searches),0) as month_ct_searches
	,ISNULL(month_clicks/nullif(month_ct_searches,0)::numeric,0) as month_sov
	from(
		select
		--date_trunc('month', date)::date as month
		case
			when user_country_id_name = 'Algeria' then 'AA'
			when user_country_id_name = 'Bahrain' then 'AA'
			when user_country_id_name = 'Comoros' then 'AA'
			when user_country_id_name = 'Djibouti' then 'AA'
			when user_country_id_name = 'Egypt' then 'AA'
			when user_country_id_name = 'Iraq' then 'AA'
			when user_country_id_name = 'Jordan' then 'AA'
			when user_country_id_name = 'Kuwait' then 'AA'
			when user_country_id_name = 'Lebanon' then 'AA'
			when user_country_id_name = 'Libya' then 'AA'
			when user_country_id_name = 'Mauritania' then 'AA'
			when user_country_id_name = 'Morocco' then 'AA'
			when user_country_id_name = 'Oman' then 'AA'
			when user_country_id_name = 'Qatar' then 'AA'
			when user_country_id_name = 'Saudi Arabia' then 'AA'
			when user_country_id_name = 'Somalia' then 'AA'
			when user_country_id_name = 'Sudan' then 'AA'
			when user_country_id_name = 'Syria' then 'AA'
			when user_country_id_name = 'Tunisia' then 'AA'
			when user_country_id_name = 'Yemen' then 'AA'
			when user_country_id_name = 'Hashemite Kingdom of Jordan' then 'AA'
			when user_country_id_name = 'Czechia' then 'Czech Republic'
			when user_country_id_name = 'Republic of Korea' then 'South Korea'
			when user_country_id_name = 'Réunion' then 'Reunion'
			else user_country_id_name end as user_country_id_name
		,campaign_targeting_type_name
		,0 as searches
		,count(1) as trivago_total_clicks
		,sum(advertiser_cpc) as trivago_total_cost
		From v_all_clean_clicks 
		where date >= '2022-01-01'
		AND date < '2022-02-01'
		AND advertiser_id = 156
		AND publisher_name not ilike '%parallax%'
		Group by 1,2
		union all
		Select
		--date_trunc('month', date) as month
		case
		when user_country_id_name = 'Algeria' then 'AA'
		when user_country_id_name = 'Bahrain' then 'AA'
		when user_country_id_name = 'Comoros' then 'AA'
		when user_country_id_name = 'Djibouti' then 'AA'
		when user_country_id_name = 'Egypt' then 'AA'
		when user_country_id_name = 'Iraq' then 'AA'
		when user_country_id_name = 'Jordan' then 'AA'
		when user_country_id_name = 'Kuwait' then 'AA'
		when user_country_id_name = 'Lebanon' then 'AA'
		when user_country_id_name = 'Libya' then 'AA'
		when user_country_id_name = 'Mauritania' then 'AA'
		when user_country_id_name = 'Morocco' then 'AA'
		when user_country_id_name = 'Oman' then 'AA'
		when user_country_id_name = 'Qatar' then 'AA'
		when user_country_id_name = 'Saudi Arabia' then 'AA'
		when user_country_id_name = 'Somalia' then 'AA'
		when user_country_id_name = 'Sudan' then 'AA'
		when user_country_id_name = 'Syria' then 'AA'
		when user_country_id_name = 'Tunisia' then 'AA'
		when user_country_id_name = 'Yemen' then 'AA'
		when user_country_id_name = 'Hashemite Kingdom of Jordan' then 'AA'
		when user_country_id_name = 'Czechia' then 'Czech Republic'
		when user_country_id_name = 'Republic of Korea' then 'South Korea'
		when user_country_id_name = 'Réunion' then 'Reunion'
		else user_country_id_name end as user_country_id_name
		,campaign_targeting_type_name
		,count(1) as searches
		,0 as trivago_total_clicks
		,0 as trivago_total_cost
	from v_all_searches
	where date between '${start_month}' and date '${start_month}' + interval '1 month'
			and publisher_name not ilike '%parallax%'
	group by 1,2
)
group by 1,2



