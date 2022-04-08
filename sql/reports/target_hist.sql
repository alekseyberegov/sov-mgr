select model
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
		and advertiser_id = ${advertiser_id}
	order by model, market, vertical, device
)
where start_date >= dt
group by 1, 2, 3, 4
order by 1, 2, 3, 4