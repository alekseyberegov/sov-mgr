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

### Reported SOV
* device
* brand
* country
* vertical
* sov

#### File name
```
    <advertiser>"_"<report-name>"_"<YYYY>-<MM>".csv"
```

## Generating SOV stats
* Kayak
  ```
  ../scripts/rsql.sh -p "start_month=2022-01-01" -p "user=aleksey" -s ../sql/sov/sov_kayak.sql > kayak_market-sov_2022-01.csv
  ```
* Trivago
  ```
  ../scripts/rsql.sh -p "start_month=2022-02-01" -p "user=aleksey" -s ../sql/sov/sov_trivago.sql > trivago_market-sov_2022-02.csv
  ```
* Booking
  ```
  ../scripts/rsql.sh -p "start_month=2022-02-01" -p "user=aleksey" -s ../sql/sov/sov_bcom.sql > bcom_market-sov_2022-02.csv
  ```
