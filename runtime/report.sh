#!/bin/bash -e

result_dir=$1

connections_list=$(ls $result_dir | cat | sed 's/.*-c\([0-9]\+\)-\(baseline\|javaagent\)/\1/' | sort -n | uniq)

for connections in $connections_list;
do
  baseline=$(grep Requests/sec $result_dir/*-c$connections-baseline | awk '{ print $2 }' | sort -n | awk '{ arr[NR] = $1 } END { if (NR % 2 == 1) print arr[(NR + 1) / 2]; else print (arr[NR / 2] + arr[NR / 2 + 1]) / 2 }')
  javaagent=$(grep Requests/sec $result_dir/*-c$connections-javaagent | awk '{ print $2 }' | sort -n | awk '{ arr[NR] = $1 } END { if (NR % 2 == 1) print arr[(NR + 1) / 2]; else print (arr[NR / 2] + arr[NR / 2 + 1]) / 2 }')
  overhead=$(bc <<< "scale=1; 100 * ($baseline - $javaagent) / $baseline")
  printf "%3s %10s %10s %10s\n" $connections $overhead $baseline $javaagent
done
