select 
	  ks.brand 
	, ks.country 
	, ks.vertical
	, '=' || ks.click_cnt || '/ VLOOKUP(\"'||country||'_'||vertical||'\",top!A:Q,11,false)' as sov
from exploratory.kayak_sov ks 
where ks.report_month = 3 and ks.brand is not null
order by ks.country, ks.vertical, ks.cost_amt desc