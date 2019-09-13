#!/bin/bash

#Open ports for the services to communicate
sudo firewall-cmd --zone=public --permanent --add-port=8080-8085/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8443/tcp
sudo firewall-cmd --reload

#Install and start Server agent for jmeter host metrics capturing
sudo yum install -y java-1.8.0-openjdk
curl -L https://github.com/undera/perfmon-agent/releases/download/2.2.3/ServerAgent-2.2.3.zip > ServerAgent.zip
unzip ServerAgent.zip

