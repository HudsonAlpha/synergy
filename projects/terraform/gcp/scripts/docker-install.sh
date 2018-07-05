#! /bin/bash

#
# Katreena Mullican
# HudsonAlpha Institute for Biotechnology
# May 2018
# This code is provided AS-IS for demonstration purposes only

#
# Install docker engine
#
if [[ -f /usr/bin/docker ]] ; then
   echo "Docker is already installed.  Exiting ..."
   exit 1
fi

#
# Wait a few seconds for networking to get settled
#
sleep 10

yum install -y docker

#
# Datadog requires docker to run as "docker" group
#
cat <<EOF > /etc/docker/daemon.json
{
    "group": "docker"
}
EOF
groupadd docker

#
# Enable and start docker engine
#
systemctl enable docker
systemctl start docker

exit 0
