delete from kayak_sov 


update kayak_sov 
set prev_cost = cast(replace(prev_cost, ',', '') as decimal),
	cur_cost  = cast(replace(cur_cost, ',', '') as decimal)
	

update kayak_sov 
set prev_clicks = cast(replace(prev_clicks, ',', '') as integer),
	cur_clicks  = cast(replace(cur_clicks, ',', '') as integer)
	
update kayak_sov 
set 
prev_sov = replace(prev_sov, '%', '') / 100, 
prev_rep_sov = replace(prev_rep_sov, '%', '') / 100, 
cur_sov = replace(cur_sov, '%', '') / 100, 
cur_adj_sov = replace(cur_adj_sov, '%', '') / 100, 
cur_cal_sov = replace(cur_cal_sov, '%', '') / 100, 
cur_fin_sov = replace(cur_fin_sov, '%', '') / 100