#!/bin/bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell

# Initialize our own variables
separator=","
verbose=0
script=$0

function show_help() {
    echo "Usage: $script [-h] [-s OFS] file"
}

while getopts "h?vs:" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    v)  verbose=1
      ;;
    s)  separator=$OPTARG
      ;;
  esac
done

shift $((OPTIND-1))

if [[ $# -ne 1 ]] ; then
    show_help
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

temp_file=$(mktemp)

awk -v brand_col="${brand}"  \
    -v brand_hdr="advertiser"  \
    -v date_col="${timestamp}"  \
    -v date_hdr="date"  \
    -v OFS="${separator}"  \ '{if (NR==1) print brand_hdr,date_hdr,$0; else print brand_col,date_col,$0}' \
     ${path} > ${temp_file}

aws s3 cp "${temp_file}" "s3://${bucket}/${folder}${filename}"

echo "${temp_file}"




