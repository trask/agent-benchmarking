#!/bin/bash -e

result_dir=$1

baseline=$(cat $result_dir/*-baseline | sort -n | awk '{ arr[NR] = $1 } END { if (NR % 2 == 1) print arr[(NR + 1) / 2]; else print (arr[NR / 2] + arr[NR / 2 + 1]) / 2 }')
javaagent=$(cat $result_dir/*-javaagent | sort -n | awk '{ arr[NR] = $1 } END { if (NR % 2 == 1) print arr[(NR + 1) / 2]; else print (arr[NR / 2] + arr[NR / 2 + 1]) / 2 }')
overhead=$(bc <<< "scale=1; 100 * ($javaagent - $baseline) / $baseline")
printf "%10s %10s %10s\n" $overhead $baseline $javaagent
