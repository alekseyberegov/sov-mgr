


select
	  round(100 * (cur_adj_sov / prev_rep_sov - 1), 2) as calc_sov_pct
	, change_sov_pct 
	, round(100 * (cur_cpc /  prev_cpc - 1), 2) as cal_cpc_pct
	, change_cpc_pct 
from kayak_sov ks 


select brand, count(1)
from kayak_sov ks 
group by 1


--
-- Basic checks
--
select brand_country_vertical 
	, prev_rep_sov 
	, cur_adj_sov 
from kayak_sov ks 
where abs(cur_adj_sov) > 1.0 or abs(prev_rep_sov) > 1.0

---
--- Negative Correlation
---
SELECT brand_country_vertical
	, ks.brand = m.brand as top_spend
	, ks.cur_cost 
	, ks.cur_adj_sov 
	, change_cpc_pct
	, change_sov_pct 
	, m.brand as top_spend_brand
	, m.cur_cost as top_spend_cost
	, m.cur_adj_sov as top_spend_sov
from kayak_sov ks 
	left join (
		select DENSE_RANK() over (PARTITION by country, vertical order by cur_cost desc) as rn
			, cur_cost 
			, cur_adj_sov 
			, country 
			, vertical 
			, brand
		from kayak_sov
		order by country, vertical, cur_cost desc
	) m on (rn = 1 and m.country = ks.country and m.vertical = ks.vertical)
where (ks.cur_adj_sov / ks.prev_rep_sov - 1) *  (ks.cur_cpc /  ks.prev_cpc - 1) < 0
	and ks.cur_cost > 500
order by ks.cur_cost desc, ks.country, ks.vertical 


---
--- elasticity
---
SELECT brand_country_vertical
	, ks.brand = m.brand as top_spend
	, round((ks.cur_adj_sov / ks.prev_rep_sov - 1) /  (ks.cur_cpc /  ks.prev_cpc - 1), 4) as elasticity
	, ks.cur_cost 
	, ks.cur_adj_sov 
	, change_cpc_pct
	, change_sov_pct 
	, m.brand as top_spend_brand
	, m.cur_cost as top_spend_cost
	, m.cur_adj_sov as top_spend_sov
from kayak_sov ks 
	left join (
		select DENSE_RANK() over (PARTITION by country, vertical order by cur_cost desc) as rn
			, cur_cost 
			, cur_adj_sov 
			, country 
			, vertical 
			, brand
		from kayak_sov
		order by country, vertical, cur_cost desc
	) m on (rn = 1 and m.country = ks.country and m.vertical = ks.vertical)
where (ks.cur_adj_sov / ks.prev_rep_sov - 1) *  (ks.cur_cpc /  ks.prev_cpc - 1) > 0
	and ks.cur_cost > 500
order by elasticity


--
--
--
select country, vertical
	, sum(cur_cost) as cur_cost
	, sum(cur_clicks) as cur_clicks
	, group_concat(brand||'='||round((1 + click_change_pct) / (1 + sov_change_pct) - 1, 4), '; ') as market_change
from (
	select brand
		, country
		, vertical
		, ks.cur_cost 
		, ks.prev_clicks 
		, ks.cur_clicks 
		, ks.prev_rep_sov 
		, ks.cur_adj_sov
		, round(ks.cur_cpc /  ks.prev_cpc - 1, 4) as cpc_change_pct
		, round(cast(ks.cur_clicks as float) /  ks.prev_clicks - 1, 4) as click_change_pct
		, round(ks.cur_adj_sov / ks.prev_rep_sov - 1, 4) as sov_change_pct
	from kayak_sov ks 
	where ks.cur_cost > 500
) 
group by country, vertical
order by 3 desc

--
--
--
select round(placement_size / avg_size - 1, 4) as diff, *
from (
	select brand_country_vertical
		, ks.cur_cost 
		, ks.cur_clicks 
		, ks.cur_adj_sov 
		, round(avg(ks.cur_clicks / ks.cur_adj_sov) over (PARTITION by country, vertical)) as avg_size
		, round(min(ks.cur_clicks / ks.cur_adj_sov) over (PARTITION by country, vertical)) as min_size
		, round(max(ks.cur_clicks / ks.cur_adj_sov) over (PARTITION by country, vertical)) as max_size
		, round(ks.cur_clicks / ks.cur_adj_sov) as placement_size
		, change_cpc_pct
		, change_sov_pct 
	from kayak_sov ks 
	where cur_clicks > 0 and cur_adj_sov > 0 and cur_cost > 100
	order by country, vertical 
) where abs(min_size / avg_size - 1) > 0.005 or abs(max_size / avg_size - 1) > 0.005



select country, vertical, brand
	, prev_clicks
	, prev_rep_sov
	, cast(prev_clicks / prev_rep_sov as integer) as oct_market
	, cur_clicks
	, cur_adj_sov
	, cast(case when cur_adj_sov = 0 then 0 else cur_clicks / cur_adj_sov end as integer) as nov_market
from kayak_sov
where country = 'United States' and vertical = 'Flights'

