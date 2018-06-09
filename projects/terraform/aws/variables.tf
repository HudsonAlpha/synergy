variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "cluster_name" {
    description = "Kubernetes cluster name to join"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
}

variable "ami-centos7" {
    description = "AWS CentOS 7 AMI for east region"
}

variable "aws_key_name" {
    description = "Name of keypair to embed in EC2 instances"
}

variable "aws_key_path" {
    description = "Path to the private key file"
}

variable "vpc" {
    description = "Existing VPC where instances will be provisioned"
}

variable "private_subnet" {
    description = "Private Subnet id"
}
