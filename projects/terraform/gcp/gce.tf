resource "google_compute_instance" "k8s-gcp-worker" {
  count = 1
  machine_type = "${var.machine_type}"
  zone = "${var.zone}"
  project = "${var.project}"
  name = "k8s-gcp-worker${count.index+1}"
  network_interface {
    subnetwork = "${var.private_subnet}"
    access_config {}
  }

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7-v20180611"
      size = "50"
    }
  }

 metadata {
    sshKeys = "ha-demo:${file("~/.ssh/gcp/id_rsa.pub")}"
  }

  connection {
      type = "ssh"
      user = "ha-demo"
      private_key = "${file("~/.ssh/gcp/id_rsa")}"
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
      "sudo systemctl daemon-reload",
      "sudo systemctl start docker-install ; sudo systemctl start consul-install ; sudo systemctl start datadog-install ; sudo systemctl start k8s-worker-install",
    ]
  }

}
