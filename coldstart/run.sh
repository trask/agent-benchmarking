#!/bin/bash -e

app_name=$1
run_type=$2
unique_start_id=$3
result_file=$4

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

start_time="$(date -u +%s.%3N)"

az webapp config appsettings set --name $app_name \
                                 --resource-group $app_name \
                                 --settings ApplicationInsightsAgent_EXTENSION_VERSION=$ext_version UNIQUE_START_ID=$unique_start_id

until curl -s http://$app_name.azurewebsites.net/unique-start-id | grep -q "Unique start id: $unique_start_id"
do
  sleep 1
done

end_time="$(date -u +%s.%3N)"

# fail if app is not in the correct state
curl -s http://$app_name.azurewebsites.net/Home/About | grep -q "ApplicationInsights agent is present: $agent_present"

echo "$end_time - $start_time" | bc >> $result_file
