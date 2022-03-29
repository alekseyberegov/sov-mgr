select 
	  ks.brand
	, ks.country
	, decode(ks.vertical,'-1','ALL',vertical)
    , decode(ks.device,  '-1','ALL',device)
	, '=' || ks.click_cnt || '/ VLOOKUP(\"'||decode(device,'-1','ALL',device)||'_'||country||'_'||decode(vertical,'-1','ALL',vertical)||'\",top!A:Q,11,false)' as sov
from exploratory.market_sov ks 
where ks.partition_date = '${start_month}' 
            and ks.advertiser = '${advertiser}'
                and ks.brand is not null
order by ks.country, ks.vertical, ks.device, ks.cost_amt desc