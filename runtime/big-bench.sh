#!/bin/bash -e

prefix=$1
num_parallel=$2
num_iterations=$3
path=${4:-/}
num_connections_list=${5:-1 2 4 8 16 32 64 128}
warmup_time=${6:-60s}
run_time=${7:-60s}

mkdir -p $prefix

for i in $(seq $num_parallel)
do
  ./bench.sh $prefix$i \
             $num_iterations \
             $path \
             "$num_connections_list" \
             $warmup_time \
             $run_time \
             $prefix/results \
             > $prefix/out$i 2>&1 &
done
