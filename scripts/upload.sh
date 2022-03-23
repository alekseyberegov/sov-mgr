#!/bin/bash

if [[ $# -ne 1 ]] ; then
  echo "Usage: $0 <file>"
  exit 1	
fi

path=$1
filename="${path##*/}"

if [[ $filename =~ (.*)_(.*)_(.*)-(.*)\.csv$ ]]; then
    brand=${BASH_REMATCH[1]}
    report=${BASH_REMATCH[2]}
    year=${BASH_REMATCH[3]}
    month=${BASH_REMATCH[4]}
else
    echo "The file name should have the following format: <brand>_<report>_<month>-<year>.csv"
    exit 1
fi

bucket="ct-prod-exploratory"
timestamp="${year}-${month}-01"
folder="reports/${report}/${timestamp}/"

# Create the folder for the report
aws s3api put-object --bucket ${bucket} --key ${folder}

column_cnt=$(head -1 ${path} | sed 's/[^,]//g' | wc -c)
column_cnt=$((columns + 2))

temp_file=$(mktemp)

awk -v brand_col="${brand}"  \
    -v brand_hdr="advertiser"  \
    -v date_col="${timestamp}"  \
    -v date_hdr="date"  \
    -v OFS=","  \ '{if (NR==1) print brand_hdr,date_hdr,$0; else print brand_col,date_col,$0}' \
     ${path} > ${temp_file}

aws s3 cp "${temp_file}" "s3://${bucket}/${folder}${filename}"

echo "${temp_file}"




