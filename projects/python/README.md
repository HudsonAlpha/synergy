# Synergy Provisioning via Image Streamer and Python  
  
The HudsonAlpha artifact bundle and scripts are used to provision 3 use cases:  
Docker CentOS 7.3  
OpenStack all-in-one  
OpenStack compute node  
  
## Pre-requisites
  
Single HPE Synergy frame with ImageStreamer module and at least one available node  
Image Streamer Deployment Plan and Golden Image (see docs)  
OneView template defined for the desired use case(s) (named "Docker CentOS 7.3", "OpenStack all-in-one", and "Openstack Compute")
Orchestration server with Python >= 3.4 and Python library for HPE OneView installed (https://github.com/HewlettPackard/python-hpOneView)  
Hashicorp Consul cluster with at least 1 server     
DataDog Account (optional, if DataDog plan script is used)  
  
## Configure orchestration node  
  
Server running CentOS 7.3 OS  
Must have network connectivity to HPE Synergy Composer IP  
Install python >= 3.4  
Install python-hpOneView per https://github.com/HewlettPackard/python-hpOneView  
Generate SSH keypair that will be used to communicate with Synergy nodes once they are provisioned  
Create /hpov/haconfig.json with Synergy OneView credentials
Clone this repo  
Modify <project>/config_.py files for your environment  
  
## Install and configure Hashicorp Consul single server  
  
```
This is an example of a dev Consul cluster, with just a single server:
docker run -d --name=consul --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -p 8400:8400 -p 8500:8500 -p 8600:53/udp consul agent -server -bind=<orchestration node IP address> -bootstrap-expect 1

Create key,value pair containing SSH public key:
consul kv put synergy/root "$(cat <file containing your SSH public key file>)"  
  
Optional (if DataDog plan script is used), create key,value pair containing DataDog API key::
consul kv put synergy/datadog '<DataDog API key>'  
```

## Provision nodes  

Provision Docker CentOS 7.3 node  
```
cd projects/python/common
export PYTHONPATH=../docker
./server_profile_with_streamer.py config_docker.py
```

Provision OpenStack all-in-one node
```
cd projects/python/common
export PYTHONPATH=../openstack
./server_profile_with_streamer.py config_openstack_allinone.py
```

Provision OpenStack compute node
```
cd projects/python/common
export PYTHONPATH=../openstack
./server_profile_with_streamer.py config_openstack_compute.py
SSH to OpenStack controller node
# su - packstack
$ sed -i '/^CONFIG_COMPUTE_HOSTS=/ s/$/,<IP of compute node>/' <answerfile>
$ packstack --answer-file=<answerfile>
```
  
## Built With
* CentOS 7.3.1611  
* Python 3.4.5  
* python-hpOneView 4.0.0
  
## Contact  
Email: cloud-composers@hudsonalpha.org  
Twitter: @katmullican
  
## Join the cloud-composers Slack community!  
http://www.hudsonalpha.org/cloud-composers  
  

## Authors

* **Katreena Mullican** - *Initial work* - [HudsonAlpha Instite for Biotechnology](http://www.hudsonalpha.org)
