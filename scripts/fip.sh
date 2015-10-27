#!/bin/bash

# Get admin credentials
. ~/devstack/openrc admin admin

# associate
# disassociate

echo "$1 $2"

if [ "$1" == "associate" ]; then
    echo "Associating FIP"

    # $2 == private port IP
    PRIVIP=$2

    # Allocate a FIP
    PUBNET=$(neutron net-list | grep public | cut -d " " -f 2)
    FIPID=$(neutron floatingip-create $PUBNET | grep " id " | cut -d '|' -f 3)

    # Get the ID of the local port for the local IP
    PRIVPORTID=$(neutron port-list | grep "$PRIVIP" | cut -d " " -f 2)

    SUBNETID=$(neutron subnet-list| grep 10.10.10 | cut -d " " -f 2)

    # Is the router-interface already there
    ROUTERCHECK=$(neutron router-port-list router1 | grep $SUBNETID)
    
    if [ X"${ROUTERCHECK}" == "X" ]; then
        # Add router-interface
        ROUTERID=$(neutron router-list| grep router1 | cut -d " " -f 2)
        echo "Adding router interface for router $ROUTERID and subnet $SUBNETID"
        neutron router-interface-add $ROUTERID subnet=$SUBNETID
    fi

    # Associate the FIP to the IP
    echo "Associating FIP $FIPID to port $PRIVPORTID"
    neutron floatingip-associate $FIPID $PRIVPORTID
elif [ "$1" == "disassociate" ]; then
    echo "Disassociating FIP"

    # $2 == FIP IP to delete
    FIPIP=$2

    # Get the FIP ID
    FIPID=$(neutron floatingip-list | grep $FIPIP | cut -d " " -f 2)

    # Disassociate the FIP
    neutron floatingip-disassociate $FIPID

    # Delete the FIP
    neutron floatingip-delete $FIPID
fi
