#!/bin/bash -e

prefix=$1
num_parallel=$2
num_iterations=$3

mkdir -p $prefix

for i in $(seq $num_parallel)
do
  ./bench.sh $prefix$i \
             $num_iterations \
             $prefix/results \
             > $prefix/out$i 2>&1 &
done
