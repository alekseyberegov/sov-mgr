#!/bin/bash

port="4444"
database="analytics"

if [[ -z "${POSTGRESQL_BIN}" ]]; then
    echo "Please set POSTGRESQL_BIN environment variable"
    exit 1
fi

function usage() {
    echo "Usage: $0 -s <script> -p|--param <param>"
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
            -s|--script)
                script="$2"
                shift
            ;;
            -p|--param)
                eval "$2"
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

function template() {
    local line
    while read -r line ; do
        while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo "\"$LHS\"")"
            line=${line//$LHS/$RHS}
        done
        echo "$line"
    done
}

parse_args "$@"

if [[ -z "${script}" ]]; then
    echo "Please specify the script using: -s or --script"
    exit 1
fi

# start a ssh tunnel for redshift
ssh -N -f -i ~/.ssh/id_rsa -L "${port}:redshift.prod.clicktripz.com:5439" "${user}@dev.clicktripz.com"

# run SQL
echo "" | cat "${script}" - | template | ${POSTGRESQL_BIN}/psql -t -A -F',' -h localhost -p ${port} -U ${user} ${database}

# get PID for the ssh tunnel
pid=$(ps -A | grep "ssh" | grep redshift | awk '{print $1}')

# kill the ssh tunnel
kill ${pid}
