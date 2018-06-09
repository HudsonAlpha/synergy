resource "aws_security_group" "k8s-worker" {
    name = "k8s-worker"

    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        self = "true"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${var.vpc}"

    tags {
      Cluster = "${var.cluster_name}"
    }
}
