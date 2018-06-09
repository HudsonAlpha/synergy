#! /bin/bash

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
