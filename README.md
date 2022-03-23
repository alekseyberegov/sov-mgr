# SOV Reporting System

## File Layouts
### SOV stats
* month
* advertiser
* brand
* placement
* country
* vertical
* device
* cost_amt
* click_cnt
* avg_cpc_meas
* search_cnt
* sov_meas

## Generating SOV stats
* Kayak
```
../scripts/rsql.sh -p "start_month=2022-01-01" -p "user=aleksey" -s ./sov_kayak.sql 
```
* Trivago
```
../scripts/rsql.sh -p "start_month=2022-01-01" -p "user=aleksey" -s ./sov_trivago.sql 
```

