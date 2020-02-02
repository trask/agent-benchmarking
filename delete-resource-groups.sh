#!/bin/bash

prefix=$1
num=$2

subscription=8938312c-1467-4f13-8676-62397dfcdaa1

for i in $(seq $num)
do
  az group delete --name $prefix$i \
                  --subscription $subscription \
                  --no-wait \
                  --yes
done

