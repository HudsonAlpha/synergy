resource "aws_instance" "k8s-aws-worker" {
  count = 1
  instance_type = "t2.small"
  ami = "${var.ami-centos7}"
  subnet_id = "${var.private_subnet}"
  vpc_security_group_ids = ["${aws_security_group.k8s-worker.id}"]
  key_name = "${var.aws_key_name}"

  root_block_device {
    volume_size = "50"
  }

  tags {
    Name = "k8s-aws-worker${count.index+1}"
    Cluster = "${var.cluster_name}"
    Datadog = "true"
  }

  connection {
      user = "centos"
      private_key = "${file(var.aws_key_path)}"
  }

  provisioner "file" {
    source      = "service-files/"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "scripts/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/*.sh /usr/local/bin",
      "sudo mv /tmp/*.service /etc/systemd/system",
      "sudo mv /tmp/*.target /etc/systemd/system",
      "sudo rm /etc/systemd/system/default.target",
      "sudo mkdir /etc/systemd/system/runlast.target.wants",
      "sudo ln -s /etc/systemd/system/runlast.target /etc/systemd/system/default.target",
      "sudo ln -s /etc/systemd/system/datadog-install.service /etc/systemd/system/runlast.target.wants/datadog-install.service",
      "sudo ln -s /etc/systemd/system/consul-install.service /etc/systemd/system/runlast.target.wants/consul-install.service",
      "sudo ln -s /etc/systemd/system/docker-install.service /etc/systemd/system/runlast.target.wants/docker-install.service",
      "sudo ln -s /etc/systemd/system/k8s-worker-install.service /etc/systemd/system/runlast.target.wants/k8s-worker-install.service",
      "sudo chmod +x /usr/local/bin/*.sh",
      "sudo hostnamectl set-hostname --static k8s-aws-worker${count.index+1}",
      "echo 'preserve_hostname: true' | sudo tee --append /etc/cloud/cloud.cfg.d/99_hostname.cfg > /dev/null",
      "sudo systemctl daemon-reload",
      "sudo systemctl start docker-install ; sudo systemctl start consul-install ; sudo systemctl start datadog-install ; sudo systemctl start k8s-worker-install",
    ]
  }

}
