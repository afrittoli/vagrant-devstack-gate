#!/bin/bash
# Setup the basic requirements to run d-g reproduce.sh on a fresh
# Xenial box. This is meant to be run as root.
#
# TODO(andreaf) This may be nicer as an ansible script

BASE=/opt/stack
DEV=/dev/sdc

# Setup 2nd disk
parted ${DEV} mklabel msdos
parted ${DEV} --script -- mkpart primary linux-swap 1 8192
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
