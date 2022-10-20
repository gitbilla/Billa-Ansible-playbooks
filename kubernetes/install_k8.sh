#!/bin/bash
# https://admintuts.net/server-admin/automation/kubernetes-automated-bash-install-script/     :  Script for installation
# https://clouddocs.f5.com/training/community/containers/html/appendix/appendix8/appendix8.html   :  calico
echo "Disabling swap...."
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo "Installing necessary dependencies...."
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
echo "Setting up hostname...."
#sudo hostnamectl set-hostname "k8s-master"
PUBLIC_IP_ADDRESS=`hostname -I|cut -d" " -f 1`
sudo echo "${PUBLIC_IP_ADDRESS}  ${HOSTNAME}" >> /etc/hosts
echo "Removing existing Docker Installation...."
sudo apt-get purge aufs-tools docker-ce docker-ce-cli containerd.io pigz cgroupfs-mount -y
sudo apt-get purge kubeadm kubernetes-cni -y
sudo rm -rf /etc/kubernetes
sudo rm -rf $HOME/.kube/config
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/docker
sudo rm -rf /opt/containerd
sudo apt autoremove -y

echo "Installing Docker...."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
### Add Docker apt repository.
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

## Install Docker CE.
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Setup daemon.

sudo mkdir -p /etc/systemd/system/docker.service.d

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
# Restart docker.
sudo usermod -aG docker $USER
sudo systemctl daemon-reload
sleep 5
sudo systemctl restart docker
echo "Setting up Kubernetes Package Repository..."
sudo apt-get install apt-transport-https curl -y
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
echo "Installing Kubernetes..."
sudo apt install kubeadm -y


sudo kubeadm init --pod-network-cidr=10.244.0.0/16
sudo sleep 10
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo "Installing Calico ..."
sudo curl https://docs.projectcalico.org/manifests/calico.yaml -O

echo "Kubernetes Installation finished..."
echo "Waiting 30 seconds for the cluster to go online..."
sudo sleep 30
sudo export KUBECONFIG=$HOME/.kube/config
echo "Testing Kubernetes namespaces..."
kubectl get pods --all-namespaces
echo "Testing Kubernetes nodes..."
kubectl get nodes
echo " ################  END of SCRIPT ######################### "
echo "------------------------------------------------------------------------------------------"
echo "  "
echo "  "
echo "
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --v=5

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
vim calico.yaml # change the line number 

4551             - name: CALICO_IPV4POOL_CIDR
4552               value: "192.168.0.0/16

kubectl apply -f calico.yaml
"
