#!/bin/bash

#Open ports for the services to communicate
sudo firewall-cmd --zone=public --permanent --add-port=8080-8085/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8443/tcp
sudo firewall-cmd --reload

#Install the cli
curl -L -O https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
chmod +x install.sh
./install.sh --accept-all-defaults
rm install.sh



