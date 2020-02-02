#!/bin/bash -e

set -o pipefail

app_name=$1
run_type=$2
unique_start_id=$3
connections=$4
warmup_time=$5
run_time=$6
path=$7
result_file=$8

if [ "$run_type" == "baseline" ]
then
  ext_version=disabled
  agent_present=false
else
  ext_version=~2
  agent_present=true
fi

echo ==================
date
echo waiting for app...
echo ==================

az webapp config appsettings set --name $app_name \
                                 --resource-group $app_name \
                                 --settings ApplicationInsightsAgent_EXTENSION_VERSION=$ext_version UNIQUE_START_ID=$unique_start_id

until curl -s http://$app_name.azurewebsites.net/unique-start-id | grep -q "Unique start id: $unique_start_id"
do
  sleep 1
done

# fail if app is not in the correct state
curl -s http://$app_name.azurewebsites.net/Home/About | grep -q "ApplicationInsights agent is present: $agent_present"

# cold start
curl -s http://$app_name.azurewebsites.net$path > /dev/null

echo =================
date
echo running warmup...
echo =================

# warmup
wrk -t1 -c$connections -d$warmup_time http://$app_name.azurewebsites.net$path

echo ====================
date
echo running benchmark...
echo ====================

# benchmark
wrk -t1 -c$connections -d$run_time http://$app_name.azurewebsites.net$path | tee $result_file
