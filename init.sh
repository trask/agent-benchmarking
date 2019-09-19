#!/bin/bash -e

sudo apt-get update
sudo apt-get install build-essential libssl-dev git -y
git clone https://github.com/wg/wrk.git wrk
(cd wrk && make)
sudo cp wrk/wrk /usr/local/bin
rm -rf wrk

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --name application-insights
