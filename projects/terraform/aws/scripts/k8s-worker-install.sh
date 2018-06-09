#! /bin/bash

#
# Katreena Mullican
# HudsonAlpha Institute for Biotechnology
# October 2017
#
# Setup a k8s minion and join to master
#

#
# Disable selinux and set disabled for future boots
#
echo "Disabling SELinux"
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#
# Disable firewalld
#
echo "Disabling firewalld"
systemctl stop firewalld
systemctl disable firewalld

#
# Disable swap
#
echo "Disabling swap"
swapoff -a
sed -i '/swap/d' /etc/fstab

#
# Setup yum repo for k8s
#
echo "Creating yum repo"

cat <<EOF > /etc/yum.repos.d/k8s.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#
# Install kubeadm
#
echo "Installing kubeadm"
yum install -y kubeadm
systemctl enable kubelet
echo "Starting kubelet"
systemctl start kubelet

#
# Get the join command from Consul
#
sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=-.*#Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --cgroup-driver=systemd"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
JOIN_CMD=$(docker exec consul consul kv get k8s/hybrid-k8s/join)
if [[ $(echo $JOIN_CMD | grep -c "kubeadm") -eq 0 ]] ; then
   echo "K8s join command not found in Consul.  Did the master node deploy OK and write to Consul?"
   exit 1
fi

#
# Join the k8s cluster
#
$JOIN_CMD

exit 0
