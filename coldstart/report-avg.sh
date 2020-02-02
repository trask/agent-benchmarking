#!/bin/bash -e

result_dir=$1

baseline=$(cat $result_dir/*-baseline | awk '{ sum += $1 } END { print sum / NR }')
javaagent=$(cat $result_dir/*-javaagent | awk '{ sum += $1 } END { print sum / NR }')
overhead=$(bc <<< "scale=1; 100 * ($javaagent - $baseline) / $baseline")
printf "%10s %10s %10s\n" $overhead $baseline $javaagent
