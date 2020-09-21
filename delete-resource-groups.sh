#!/bin/bash

prefix=$1
num=$2

subscription=65b2f83e-7bf1-4be3-bafc-3a4163265a52

for i in $(seq $num)
do
  az group delete --name $prefix$i \
                  --subscription $subscription \
                  --no-wait \
                  --yes
done

