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

## Databases
* exploratory.advertiser_sov
* exploratory.market_sov

## Generate Reports
* Geneate market SOVs 
* Transform client SOVs
* Upload SOVs
### Generating market SOVs 
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
* Shorcut
  ```
  ../scripts/sov.sh -u aleksey -a bcom -m "2022-02"
  ```
### Transforming client SOVs
* Booking
  ```
  ../scripts/transform.py -c "0,1,3,4" ./bcom_sov_mar.csv -n "0%" -p "-1" -r "3,1,2,0,4" > bcom_client-sov_2022-03.csv
  ```
* Trivago
  ```
  ../scripts/transform.py -c "0,1,2,4" ./trivago_sov_mar.csv -n "0%" -p "-1" > trivago_client-sov_2022-03.csv
  ```
* Kayak
  ```
  ../scripts/transform.py -c "0,1,2,4" ./kayak_sov_mar.csv -n "0%" -p "-1" > kayak_client-sov_2022-03.csv
  ```
### Uploading SOVs
* Uploading Client Sovs
  ```
  ../scripts/upload.sh trivago_client-sov_2022-03.csv
  ../scripts/upload.sh kayak_client-sov_2022-03.csv
  ../scripts/upload.sh bcom_client-sov_2022-03.csv
  ```
* Uploading Market SOVs
  ```
  ../scripts/upload.sh -s "|" trivago_market-sov_2022-04.csv
  ../scripts/upload.sh -s "|" kayak_market-sov_2022-04.csv
  ../scripts/upload.sh -s "|" bcom_market-sov_2022-04.csv
  ```
