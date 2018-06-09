#! /bin/bash

#
# Check to see if container exists from previous install
#
if docker ps -a | grep -q consul ; then
   echo "Consul container already exists.  Deleting it ...."
   docker stop consul
   docker rm consul
fi

echo "Installing Consul agent"

#
# IP address of consul server
#
CONSUL_SERVER_IP=""

#
# Be sure consul server can be reached (by ping)
#
CONNECT=""
while [[ $CONNECT != "ok" ]] ; do
   echo "attemping to ping consul server ..."
   CONNECT=$(ping -q -w 1 -c 1 "$CONSUL_SERVER_IP" > /dev/null && echo "ok" || echo "error")
   sleep 2
done

#
# Get the external interface name and IP address
#
EXT_IFACE=$(ip route | grep default | awk '{print $5}')
EXT_IP=$(ip a | grep $EXT_IFACE | grep inet | awk '{print $2}' | awk -F"/" '{print $1}')

#
# Install the agent
#
mkdir -p /consul/data
mkdir -p /consul/config

echo "executing docker run ..."
docker run -d --name="consul" --net=host -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true,"disable_remote_exec": false}' consul agent -bind=$EXT_IP -retry-join=$CONSUL_SERVER_IP

exit 0
