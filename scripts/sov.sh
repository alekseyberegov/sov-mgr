#!/bin/bash

function usage() {
    echo "Usage: $0 -u|--user <user> -a|--advertiser <advertiser> -m|--month <YYYY-MM>"
    exit 1
} 

function parse_args()
{
     unknown_args=()

    # Parse the command line parameters
    while [[ $# -gt 0 ]]
    do
        case $1 in
            -h|--help)
                usage
            ;;
            -v|--verbose)
                verbose="on"
            ;;
            -a|--advertiser)
                advertiser="$2"
                shift
            ;;
            -m|--month)
                month="$2"
                shift
            ;;
            -u|--user)
                user="$2"
                shift
            ;;
            *)
                unknown_args+=("$1")
            ;;
        esac
        shift
    done
    set -- "${unknown_args[@]}"
}

parse_args "$@"

if [[ -z "${month}" ]]; then
    echo "Please specify -m|--month parameter"
    exit 1
fi

if [[ -z "${user}" ]]; then
    echo "Please specify -u|--user parameter"
    exit 1
fi

if [[ -z "${advertiser}" ]]; then
    echo "Please specify -a|--advertiser parameter"
    exit 1
fi

SRC_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REP_FILE="${SRC_DIR}/../datafiles/${advertiser}_market-sov_${month}.csv"
SQL_FILE="${SRC_DIR}/../sql/sov/sov_${advertiser}.sql"

${SRC_DIR}/rsql.sh -p "start_month=${month}-01" -p "user=${user}" -s "${SQL_FILE}" > "${REP_FILE}"