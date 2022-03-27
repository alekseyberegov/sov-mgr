#! /bin/bash

function usage() {
    echo "Usage: $0 -c|--columns <columns> -v|--nvl <not-a-value> -p|--prepend <prepend>"
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
            -c|--columns)
                read -a columns <<< $2
                shift
            ;;
            -n|--nvl)
                nvl="$2"
                shift
            ;;
            -p|--prepend)
                read -a prepend <<< $2
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


function parse_line() {
    cn=0
    pn=0
    for col_val in $@
    do
        cn=$((cn + 1))

        pr=0
        if [[ "${columns}" == "*" ]] ; then
            pr=1
        else 
            if [[ " ${columns[*]} " =~ " ${cn} " ]]; then
                pr=1
            fi
        fi

        if [[ "${pr}" == "1" ]] ; then
            pn=$((pn + 1))
            [[ "${pn}" -ne "1" ]] && echo -n  ","
            if [[ "${col_val}" == "#N/A" || "${col_val}" == "#DIV/0!" ]] ; then
                pr_val="${nvl}"
            else 
                if [[ $col_val == *","* ]]; then
                    pr_val="\"${col_val}\""
                else
                    pr_val="${col_val}"
                fi
            fi
            echo -n "${pr_val}"
        fi
    done
}

nvl=""
columns="*"

parse_args "$@"

rn=0
while IFS=, read -r -a line
do 
    rn=$((rn + 1))
    parse_line "${line[@]}"
    echo        
done