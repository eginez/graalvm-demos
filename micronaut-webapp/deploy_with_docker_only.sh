#!/bin/bash
set -eu

# $1 worker service docker image name
# $2 external ip of worker service
# $3 load generation service docke image name
# $4 external ip of host for load generation
# $5 interal ip of worker service (to be used by load generation)
# $6 name of the test

WORKER_SERVICE_PORT=8443
RES_OUTPOUT=./res-$6-`date "+%Y-%m-%d-%H.%M"`

echo "Deploying $1 to $2"
docker save $1|pv|ssh -o StrictHostKeyChecking=no $2 "docker load"

echo "Start host metrics agent on $2"
ssh -o StrictHostKeyChecking=no  $2  "nohup ./ServerAgent-2.2.3/startAgent.sh --tcp-port 8085 --udp-port=0 &"

echo "Deploying $3 to $4"
docker save $3|pv|ssh -o StrictHostKeyChecking=no $4 "docker load"

echo "Starting $1"
ssh -o StrictHostKeyChecking=no $2 "docker run -d -p $WORKER_SERVICE_PORT:$WORKER_SERVICE_PORT $1"

echo "Starting load-test"
ssh -o StrictHostKeyChecking=no $4 "mkdir -p /home/opc/res && docker run -i -v /home/opc/res:/tmp/res:Z -e TODOSERVICE_HOST=$5 -e TODOSERVICE_PORT=$WORKER_SERVICE_PORT -e LOADTESTS_RESULTS=/tmp/res $3"

echo "Saving results"
ssh $4 "tar -cf res.tar ./res"
scp $4:/home/opc/res.tar $RES_OUTPOUT.tar
echo "Saved to $RES_OUTPOUT.tar"



