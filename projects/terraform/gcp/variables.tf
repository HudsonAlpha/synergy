variable "zone"{
  description = "Google cloud zone"
  default = "us-east1-b"
}

variable "project"{
  description = "Project name"
}

variable "credentials"{
  description = "Credentials JSON filename"
}

variable "machine_type"{
  description = "GCE machine type"
  default = "n1-standard-1"
}

variable "ssh_user"{
  description = "Username for SSH connection"
}

variable "ssh_pubkey"{
  description = "Full path to public SSH key"
}

variable "ssh_privkey"{
  description = "Full path to private SSH key"
}

variable "cluster_name" {
    description = "Kubernetes cluster name to join"
}

variable "private_subnet" {
    description = "Name of Google cloud private subnet"
}
