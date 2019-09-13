#!/bin/sh
image_name=todo-service-native
docker_file=Dockerfile
quiet=false

if [ "$1" = "-q" ]
then
    quiet=true
    shift
fi

case "$1" in
    graalvm* )
    image_name=todo-service-graalvm
    docker_file=Dockerfile-graalvm
    ;;
    hotspot*)
    image_name=todo-service-hotspot
    docker_file=Dockerfile-hotspot
    ;;
esac

docker build -f $docker_file .  -t $image_name
if [ "${quiet}" = false ]
then
    echo
    echo
    echo "To run the docker container execute:"
    echo "     $docker run -it -p 8443:8443 -p 8085:8085 -e \"JMX_HOST=192.168.1.104\" $image_name"
fi

