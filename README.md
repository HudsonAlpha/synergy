# HPE Synergy Community Project  
  
This repo is maintained by HudsonAlpha Institute for Biotechnology.  The purpose is to share Synergy Image Streamer Artifact Bundles and python scripts
 that can be used to provision infrastructure for OpenStack, Docker, and Kubernetes projects.  These scripts require Synergy OneView version >= 3.10.  
  
# Use cases   
  
The HudsonAlpha Artifact Bundle and Python scripts are used to provision 6 use cases:  
* Docker-CE bare metal CentOS 7.4  
* Docker-CE bare metal Fedora 27  
* OpenStack Queens all-in-one  
* OpenStack Queens compute node  
* Kubernetes master node  
* Kubernetes minion node  
  
## Pre-requisites
  
* HPE Synergy frame (OneView >= 3.1) with ImageStreamer module and at least one unused node  
* Artifact Bundle from this repo extracted into Image Streamer    
* Image Streamer Golden Image (create your own, see docs)  
* Image Streamer Deployment Plan (create your own, combine an OS Build Plan from Artificat Bundle and your Golden Image)  
* OneView template defined for each desired use case -- template should include a Deployment Plan with all custom attribute values set to 'tbd'  
* Orchestration server (see below for config)  
* Hashicorp Consul cluster with at least 1 server (see below for config)  
* DataDog Account (optional, if DataDog Plan Script is used)  
  
## Configure orchestration server  
  
1. Install OS (recommend CentOS 7.4)   
2. Ensure network connectivity to HPE Synergy OneView Composer IP  
3. Install docker (yum install -y docker)  
4. Install python >= 3.4 (yum install -y epel-release ; yum install -y python34 python34-pip)   
5. Install python-hpOneView per README: https://github.com/HewlettPackard/python-hpOneView  
6. Generate SSH keypair that will be used to communicate with Synergy nodes once they are provisioned (ssh-keygen)   
7. Create /hpov/config.json with Synergy OneView credentials:      
```
{
  "ip": "",
  "image_streamer_ip": "",
  "api_version": 500,
  "credentials": {
    "userName": "",
    "authLoginDomain": "",
    "password": ""
  }
}
```
8. Clone this repo (git clone https://github.com/HudsonAlpha/synergy.git)  
9. Modify projects/python/<usecase>/config_<xxx>.py files for your environment  
  
## Install and configure Hashicorp Consul single server  
  
```
This is an example of a dev Consul cluster, with just a single server:
docker run -d --name=consul --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' -p 8400:8400 -p 8500:8500 -p 8600:53/udp consul agent -server -bind=<orchestration node IP address> -bootstrap-expect 1

Create key,value pair containing SSH public key:
consul kv put synergy/root "$(cat <file containing your SSH public key file>)"  
  
Optional (if DataDog plan script is used), create key,value pair containing DataDog API key:
consul kv put synergy/datadog '<DataDog API key>'  
```

## Provision nodes  

Provision Docker CentOS 7.4 or Docker Fedora 27 node  
```
cd projects/python/common
export PYTHONPATH=../docker
./server_profile_with_streamer.py config_docker_centos.py
./server_profile_with_streamer.py config_docker_fedora.py
```

Provision Kubernetes master or minion node  
```
cd projects/python/common
export PYTHONPATH=../k8s
./server_profile_with_streamer.py config_K8s_master.py
./server_profile_with_streamer.py config_K8s_minion.py
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
* CentOS 7.4, Fedora 27
* Python 3.4.5  
* python-hpOneView 4.0.0
  
## Contact  
Email: cloud-composers@hudsonalpha.org  
Twitter: @katmullican
  
## Join the HPE Developer Slack community!  
https://www.labs.hpe.com/slack

## Authors
* **Katreena Mullican** - *Initial work* - [HudsonAlpha Instite for Biotechnology](http://www.hudsonalpha.org)

## License
This project is licensed under the MIT License - see the LICENSE file for details
