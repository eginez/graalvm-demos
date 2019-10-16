#!/bin/sh
image_name=micronaut-webapp_frontend
docker_file=Dockerfile
tag=:native
quiet=false

if [ "$1" = "-q" ]
then
    quiet=true
    shift
fi

case "$1" in
    graalvm* )
    tag=:graalvm-ce
    docker_file=Dockerfile-graalvm
    if [[ $GRAALVM_DOCKER_EE != "" ]]
    then
        echo Building graalvm-ee image
        tag=:graalvm-ee
        sed s"/oracle\/.*/$GRAALVM_DOCKER_EE as graalvm/g" $docker_file  > Docker-graalvm-ee
        docker_file=Docker-graalvm-ee
    fi
    ;;
    hotspot*)
    docker_file=Dockerfile-hotspot
    tag=:openjdk8
    ;;
    *)
    ## GRAALVM_DOCKER_EE contains the tag of the docker container with native image ee
    if [[ $GRAALVM_DOCKER_EE != "" ]]
    then
        echo Building native ee image
        tag=:native-ee
        sed s"/oracle\/.*/$GRAALVM_DOCKER_EE as graalvm/g" $docker_file | \
        sed  "/^RUN gu*/d"  > Docker-native-ee
        docker_file=Docker-native-ee
        if [[ $PROFILE_FILE != "" ]]
        then
            echo Adding pgo to the native image
            tag=$tag-pgo
            sed s"/--verbose/--verbose --pgo=$PROFILE_FILE/g" $docker_file > ${docker_file}-pgo
            docker_file=${docker_file}-pgo
        fi
    fi
    ;;
esac

docker build -f $docker_file .  -t $image_name$tag

if [ "${quiet}" = false ]
then
    echo
    echo
    echo "To run the docker container execute:"
    echo "    $ docker run -p 8080:8080 $image_name$tag"
fi
