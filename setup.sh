#!/bin/bash
# Setup the basic requirements to run d-g reproduce.sh on a fresh
# Xenial box. This is meant to be run as root.
#
# TODO(andreaf) This may be nicer as an ansible script

BASE=/opt/stack
DEV=/dev/sdc

# Setup 2nd disk
parted ${DEV} mklabel msdos
parted ${DEV} --script -- mkpart primary linux-swap 1 9216
mkswap ${DEV}1
swapon ${DEV}1
grep -q ${DEV}1 /proc/swaps || exit 1

# Install apt dependencies
apt-get update
apt-get install -y python-all-dev build-essential git libssl-dev ntp ntpdate

# Install pip and virtualenv
curl https://bootstrap.pypa.io/get-pip.py | python
pip install virtualenv

# Download the reproduce script
if [ -n "$REPRODUCE_SCRIPT" ]; then
    curl "$REPRODUCE_SCRIPT" > ~/reproduce.sh
    chmod 700 ~/reproduce.sh
fi

# Fix the reproduce script to not run tests and preserve stack user
sed -i -e '/DEVSTACK_GATE_TEMPEST_NOTESTS/s/=.*$/="1"/g' -e '/DEVSTACK_GATE_REMOVE_STACK_SUDO/s/=.*$/="0"/g' ~/reproduce.sh
# Ensure the HOST_IP is localhost for port forwarding to work
if $(grep DEVSTACK_LOCAL_CONFIG reproduce.sh); then
    sed -i '/DEVSTACK_LOCAL_CONFIG/s,="\(.*\)$,="HOST_IP=127.0.0.1\n\1,g' reproduce.sh
else
    sed -i '/ZUUL_UUID/a declare -x DEVSTACK_LOCAL_CONFIG="HOST_IP=127.0.0.1"' reproduce.sh
fi

# Setup the node
cd ~
./reproduce.sh
