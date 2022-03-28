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
## Useful commands
* Parsing CSV files
  ```
  cat trivago_sov_feb.csv | ../scripts/parser.sh -c "1 2 12" -n "0%"
  ```
* Preparing SOV reports
  ```
  ../scripts/transform.py  -c "0,1,11" ./trivago_sov_feb.csv -n "0%" -p "-1,Trivago Global" > trivago_client-sov_2022-02.csv
  ```
  ```
  ./scripts/transform.py -c "0,1,6" -n "0%"  ./bcom_sov_feb.csv -p "Booking.com,-1" -r "3,0,2,1,4" > bcom_client-sov_2022-01.csv
  ```