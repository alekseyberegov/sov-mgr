#!/bin/bash

dir=$(pwd)
files=$(ls ${dir}/*csv)

for file in $files 
do
  count=$(wc -l $file | awk '{print $1}')
  count=$((count - 1))
  
  empty=$(grep ',,' $file | wc -l)
  clean=$((count - empty))
  echo "$count $empty $clean $file"
done



