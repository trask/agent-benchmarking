#!/bin/bash -e

app_name=$1
run_type=$2
unique_start_id=$3
result_file=$4

if [ "$run_type" == "baseline" ]
then
  java_tool_options=
  agent_present=false
else
  java_tool_options=-javaagent:/home/agent.jar
  agent_present=true
fi

echo ==================
date
echo waiting for app...
echo ==================

start_time="$(date -u +%s.%3N)"

az webapp config appsettings set --name $app_name \
                                 --resource-group $app_name \
                                 --settings JAVA_TOOL_OPTIONS=$java_tool_options UNIQUE_START_ID=$unique_start_id

until [[ $(curl -s http://$app_name.azurewebsites.net/unique-start-id) == $unique_start_id ]]
do
  sleep 1
done

end_time="$(date -u +%s.%3N)"

# fail if agent is not in the correct state
[[ $(curl -s http://$app_name.azurewebsites.net/agent-check) == $agent_present ]]

echo "$end_time - $start_time" | bc >> $result_file
