# Terraform use cases  
  
Terraform is used to provision one or more Kubernetes cluster worker nodes in AWS or OneView and automatically join them to an existing K8s cluster.  It is assumed that you have already followed the main README file to provision a K8s master node and cluster and a functional Consul server in your environment.  
  
## Pre-requisites
  
* HashiCorp terraform (https://www.terraform.io/downloads.html)  
* Files from this repo extracted into terraform/aws or terraform/oneview    
* Hashicorp Consul cluster with at least 1 server (see below for config)  
* DataDog Account (optional, if DataDog Plan Script is used)  
  
## Configure orchestration server  
  
1. Install OS (recommend CentOS 7.4)   
2. Ensure network connectivity to AWS   
3. Install docker (yum install -y docker)  
4. Clone this repo (git clone https://github.com/HudsonAlpha/synergy.git)  
5. Modify projects/terraform/aws/terraform.tfvars for your environment   
6. Modify projects/terraform/aws/scripts/consul-agent-install.sh with the IP address of your Consul server   
  
## Provision nodes  

Provision K8s worker nodes in AWS  
```
cd projects/terraform/aws
terraform init
terraform plan
terraform apply
```

## Built With
* CentOS 7.4
* Terraform v0.11.7 provider.aws v1.21.0
  
## Contact  
Email: cloud-composers@hudsonalpha.org  
Twitter: @katmullican
  
## Join the HPE Developer Slack community!  
https://www.labs.hpe.com/slack

## Authors
* **Katreena Mullican** - *Initial work* - [HudsonAlpha Instite for Biotechnology](http://www.hudsonalpha.org)

## License
This project is licensed under the MIT License - see the LICENSE file for details
