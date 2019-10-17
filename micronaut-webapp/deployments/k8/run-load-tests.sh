#!/usr/bin/env bash

#This script is used to trigger the load tests against the kubernetes cluster
#$1 user@host of the vm in the same subnet as the cluster
#$2 ip of the cluster's load balancer

REMOTE_HOME=/home/opc/res
ssh ${1} "mkdir -p $REMOTE_HOME/res && \
 docker run -v $REMOTE_HOME/res:/tmp/res:Z -e LOADTESTS_RESULTS=/tmp/res -e LOADTESTS_DURATION=300 \
 -e LOADTESTS_CONC_REQS=4 -e TODOSERVICE_HOST=${2} -e TODOSERVICE_PORT=8443 eginez/loadgeneration"

res_name=$(ssh ${1} "find $REMOTE_HOME/res -name \*.tar.gz|sort|tail -n1")
scp ${1}:$res_name .
echo Results saved in $res_name

