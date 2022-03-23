#!/bin/bash

if [[ $# -ne 2 ]] ; then
  echo "Usage: $0 <file> <file>"
  exit 1	
fi

h1=$(head -1 $1)
h2=$(head -1 $2)

echo "$1: ${h1}"
echo "$2: ${h2}"

if [ "${h1}" == "${h2}" ]
then
  echo "The file headers are the same"
else
  echo "The file headers are different"
fi


