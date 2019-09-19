#!/bin/bash -e

set -o pipefail

app_name=$1
num_iterations=$2
path=$3
num_connections_list=$4
warmup_time=$5
run_time=$6
result_dir=$7

image_name=atacr01.azurecr.io/petclinic:v1
registry_url=https://atacr01.azurecr.io

mkdir -p $result_dir

function delete_resource_group() {

  echo =====================
  date
  echo deleting resources...
  echo =====================

  az group delete --name $app_name \
                  --yes

  echo =================
  date
  echo resources deleted
  echo =================

}

trap delete_resource_group EXIT

echo =====================
date
echo creating resources...
echo =====================

az group create --location westus \
                --name $app_name

instrumentation_key=$(az monitor app-insights component create --app $app_name \
                                                               --resource-group $app_name \
                                                               --location westus \
                                                               | grep instrumentationKey \
                                                               | sed 's/.*"instrumentationKey": "\(.*\)\".*/\1/')

az appservice plan create --name $app_name \
                          --resource-group $app_name \
                          --is-linux \
                          --sku P1V2

az webapp create --name $app_name \
                 --resource-group $app_name \
                 --plan $app_name \
                 --deployment-container-image-name $image_name

az webapp config appsettings set --name $app_name \
                                 --resource-group $app_name \
                                 --settings APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$instrumentation_key

az webapp config container set --name $app_name \
                               --resource-group $app_name \
                               --docker-custom-image-name $image_name \
                               --docker-registry-server-url $registry_url

# start app from fresh point
az webapp restart --name $app_name \
                  --resource-group $app_name

unique_start_id=1
# warmup
for run_type in baseline javaagent
do
  ./run.sh $app_name \
           $run_type \
           $unique_start_id \
           1 \
           $warmup_time \
           $run_time \
           $path \
           /dev/null
  unique_start_id=$((unique_start_id + 1))
done

for i in $(seq $num_iterations)
do
  for num_connections in $num_connections_list
  do
    for run_type in baseline javaagent
    do
      ./run.sh $app_name \
               $run_type \
               $unique_start_id \
               $num_connections \
               $warmup_time \
               $run_time \
               $path \
               $result_dir/$app_name-i$i-c$num_connections-$run_type
      unique_start_id=$((unique_start_id + 1))
    done
  done
done
