#!/bin/bash

NETNAME=microservices
CONTAINER1=container1
CONTAINER2=container2

if [ "$1" == "run" ]; then
    # Create the initial network
    echo "Creating demo network $NETNAME"
    sudo docker network create -d kuryr $NETNAME

    # Create two busybox containers
    echo "Creating initial containers"
    sudo docker run --publish-service=$CONTAINER1.$NETNAME.kuryr -itd \
        --name $CONTAINER1 busybox
    sudo docker run --publish-service=$CONTAINER2.$NETNAME.kuryr -itd \
        --name $CONTAINER2 busybox
elif [ "$1" == "cleanup" ]; then
    # Stop the containers
    echo "Stopping and removing containers"
    sudo docker stop $CONTAINER2
    sudo docker stop $CONTAINER1
    sudo docker rm $CONTAINER2
    sudo docker rm $CONTAINER1

    # Cleanup the published interfaces
    echo "Unpublishing the services"
    sudo docker service unpublish $CONTAINER2.$NETNAME
    sudo docker service unpublish $CONTAINER1.$NETNAME

    # Delete the network
    echo "Deleting the network"
    sudo docker network rm $NETNAME
fi
