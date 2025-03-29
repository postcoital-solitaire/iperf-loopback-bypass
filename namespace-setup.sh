#!/bin/bash
set -e



# Check if an interface is chosen
if [[ -z "$interface" ]]; then
    printf "Namespace setup error: no network interface was chosen.\n"
    exit 1
fi

# Check if IP address is chosen
if [[ -z "$address" ]]; then
    printf "Namespace setup error: no IP address was chosen.\n"
    exit 1
fi

# Check if IP address is chosen
if [[ -z "$namespace" ]]; then
    printf "Namespace setup error: no namespace was chosen.\n"
    exit 1
fi

# Check if script is run as a privileged user
if [[ $EUID -ne 0 ]]; then
    printf "Namespace setup error: this script must be run as a privileged "
    printf "user.\n"
    exit 1
fi


# Set up namespace cleanup function
namespace_created=false
cleanup()
{
    if [[ "$namespace_created" == true ]] &&
            ip netns list | awk '{print $1}' | grep -qx "$namespace"; then
        printf "Namespace setup cleanup: removing namespace \"$namespace\"... "
        ip netns del "$namespace"
        printf "complete.\n"
    fi
}
trap cleanup EXIT



# Create network namespace and assign namespace to the interface
ip netns add "$namespace"
namespace_created=true
ip link set "$interface" netns "$namespace"

# Assign IP address and enable the interface
ip netns exec "$namespace" ip addr add "$address/$subnet_mask" dev "$interface"
ip netns exec "$namespace" ip link set "$interface" up

printf "Namespace setup successful: \"$address\" at \"$interface\" in "
printf "\"$namespace\"\n"
