#!/bin/bash

total_mem=$(free | grep "Mem" | awk '{print $2}')
avail_mem=$(free | grep "Mem" | awk '{print $7}')
threshold=$((total_mem / 10))

echo " current available memory is $((avail_mem/1024/1024)) GB"

if [[ $avail_mem -le $threshold ]]; then
        echo "low mem"
else
        echo "fine"
fi
