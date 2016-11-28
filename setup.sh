#!/bin/bash
# Setup the basic requirements to run d-g reproduce.sh on a fresh
# Xenial box. This is meant to be run as root.
#
# TODO(andreaf) This may be nicer as an ansible script

BASE=/opt/stack

# Setup 2nd disk
parted /dev/sdc mklabel msdos
parted /dev/sdc mkpart primary 512 100%
mkfs.ext4 /dev/sdc1
mkdir /opt || true
echo $(blkid /dev/sdc1 | awk '{print$2}' | sed -e 's/"//g') /opt   ext4	noatime,nobarrier   0   0 >> /etc/fstab
mount /opt

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
