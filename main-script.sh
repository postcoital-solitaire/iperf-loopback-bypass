#!/bin/bash
set -e



# Network namespaces and addresses (change if not available)
: ${server_address:="10.0.0.253"}
: ${server_namespace:="isolated-iperf-server"}
: ${client_address:="10.0.0.254"}
: ${client_namespace:="isolated-iperf-client"}
: ${subnet_mask:="24"}
: ${iperf_args:=""}



# Get an array of all available network interfaces and check if provided
# interface exists.
available_interfaces=($(ls /sys/class/net))
interface="$1"
if [[ ! " ${available_interfaces[*]} " =~ " $interface " ]]; then
    printf "Main script error: provided interface does not exist. Available "
    printf "interfaces:\n${available_interfaces[*]}\n"
    exit 1
fi

# Check if chosen mode is supported
mode=$2
if [[ "$mode" != "server" ]] && [[ "$mode" != "client" ]]; then
    printf "Main script error: provided mode is not supported. Available "
    printf "modes:\nserver client\n"
    exit 1
fi

# Check if iperf3 is available
if ! command -v iperf3 &> /dev/null; then
    printf "Main script error: iperf3 command is not available, check if it's "
    printf "installed.\n"
    exit 1
fi

# Check if namespace-setup script is available
if [[ ! -f "./namespace-setup.sh" ]]; then
    printf "Main script error: missing \"namespace-setup.sh\" script. Make "
    printf "sure it's in the same directory as \"main-script.sh\".\n"
    exit 1
fi

# Check if script is run as a privileged user
if [[ $EUID -ne 0 ]]; then
    printf "Main script error: this script must be run as a privileged user.\n"
    exit 1
fi


# Launch iperf with selected mode
if [[ "$mode" == "server" ]]; then
    address="$server_address"
    namespace="$server_namespace"
    source ./namespace-setup.sh
    printf "Main script successful: setup successuful. Running iperf...\n"
    ip netns exec "$namespace" iperf3 -s ${iperf_args[@]}
else
    address="$client_address"
    namespace="$client_namespace"
    source ./namespace-setup.sh
    printf "Main script successful: setup successuful. Running iperf...\n"
    ip netns exec "$namespace" iperf3 -c "$server_address" ${iperf_args[@]}
fi
