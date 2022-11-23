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
### Generating Market SOVs 
* Kayak
  ```
  ../scripts/rsql.sh -p "start_month=2022-10-01" -p "user=aleksey" -s ../sql/sov/sov_kayak.sql > kayak_market-sov_2022-05.csv
  ```
* Trivago
  ```
  ../scripts/rsql.sh -p "start_month=2022-10-01" -p "user=aleksey" -s ../sql/sov/sov_trivago.sql > trivago_market-sov_2022-05.csv
  ```
* Booking
  ```
  ../scripts/rsql.sh -p "start_month=2022-10-01" -p "user=aleksey" -s ../sql/sov/sov_bcom.sql > bcom_market-sov_2022-05.csv
  ```
#### Shorcut
  ```
  ../scripts/sov.sh -u aleksey -m "2022-10" -a bcom 
  ../scripts/sov.sh -u aleksey -m "2022-10" -a kayak 
  ../scripts/sov.sh -u aleksey -m "2022-10" -a trivago 
  ```
### Transforming Client SOVs
* Booking
  ```
  ../scripts/transform.py -c "0,1,3,4" ./bcom_sov_sep.csv -n "0%" -p "-1" -r "3,1,2,0,4" > bcom_client-sov_2022-09.csv
  ```
* Trivago
  ```
  ../scripts/transform.py -c "0,1,2,4" ./trivago_sov_sep.csv -n "0%" -p "-1" > trivago_client-sov_2022-09.csv
  ```
* Kayak
  ```
  ../scripts/transform.py -c "0,1,2,4" ./kayak_sov_sep.csv -n "0%" -p "-1" > kayak_client-sov_2022-09.csv
  ```
Header: `brand,country,vertical,device,sov`
### Uploading SOVs
* Uploading Client SOVs
  ```
  ../scripts/upload.sh trivago_client-sov_2022-09.csv
  ../scripts/upload.sh kayak_client-sov_2022-09.csv
  ../scripts/upload.sh bcom_client-sov_2022-09.csv
  ```
* Uploading Market SOVs
  ```
  ../scripts/upload.sh -s "|" trivago_market-sov_2022-10.csv
  ../scripts/upload.sh -s "|" kayak_market-sov_2022-10.csv
  ../scripts/upload.sh -s "|" bcom_market-sov_2022-10.csv
  ```
## R-Studio config
* Kayak
```
arguments <- list(start_month="2022-10-01", 
                  advertiser="kayak", 
                  output_file="kayak-client-sov", 
                  advertiser_id="1", 
                  advertiser_brands="1, 384, 166, 422, 437, 17, 474")
```
* Booking
```
arguments <- list(start_month="2022-10-01", 
                  advertiser="bcom", 
                  output_file="bcom-client-sov", 
                  advertiser_id="8", 
                  advertiser_brands="8")
```
* Trivago
```
arguments <- list(start_month="2022-09-01", 
                  advertiser="trivago", 
                  output_file="trivago-client-sov", 
                  advertiser_id="156", 
                  advertiser_brands="156")
```