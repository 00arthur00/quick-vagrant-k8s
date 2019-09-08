# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.0"

$script = <<SCRIPT

sudo cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum -y install docker-ce
sudo service docker start
sudo systemctl enable docker
sudo mkdir -p /etc/docker
#sudo cat <<EOF > /etc/docker/daemon.json
#{
#  "registry-mirrors": ["https://***.mirror.aliyuncs.com"]
#}
#EOF

sudo systemctl daemon-reload
sudo systemctl restart docker

sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

sudo modprobe br_netfilter
sudo sysctl -p /etc/sysctl.d/k8s.conf

sudo docker pull mirrorgooglecontainers/kube-apiserver:v1.15.3-beta.0 
sudo docker pull mirrorgooglecontainers/kube-controller-manager:v1.15.3
sudo docker pull mirrorgooglecontainers/kube-scheduler:v1.15.3
sudo docker pull mirrorgooglecontainers/kube-proxy:v1.15.3
sudo docker pull mirrorgooglecontainers/pause:3.1
sudo docker pull mirrorgooglecontainers/etcd:3.3.10
sudo docker pull coredns/coredns:1.3.1
sudo docker pull quay-mirror.qiniu.com/coreos/flannel:v0.11.0-amd64

sudo docker tag mirrorgooglecontainers/kube-apiserver:v1.15.3-beta.0 k8s.gcr.io/kube-apiserver:v1.15.3
sudo docker tag mirrorgooglecontainers/kube-controller-manager:v1.15.3 k8s.gcr.io/kube-controller-manager:v1.15.3
sudo docker tag mirrorgooglecontainers/kube-scheduler:v1.15.3 k8s.gcr.io/kube-scheduler:v1.15.3
sudo docker tag mirrorgooglecontainers/kube-proxy:v1.15.3 k8s.gcr.io/kube-proxy:v1.15.3
sudo docker tag mirrorgooglecontainers/pause:3.1 k8s.gcr.io/pause:3.1
sudo docker tag mirrorgooglecontainers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
sudo docker tag coredns/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1
sudo docker tag quay-mirror.qiniu.com/coreos/flannel:v0.11.0-amd64 quay.io/coreos/flannel:v0.11.0-amd64

SCRIPT



boxes = [
    {
        :name => "k8s-master",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-worker1",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-worker2",
        :mem => "2048",
        :cpu => "2"
    }
]

Vagrant.configure(2) do |config|

  config.vm.box = "centos7"
  boxes.each do |opts|
      config.vm.define opts[:name] do |config|
        config.vm.hostname = opts[:name]
        config.vm.provider "libvirt" do |v|
          v.memory = opts[:mem]
          v.cpus = opts[:cpu]
        end

        config.vm.network :private_network, type: "dhcp"
      end
  end
  
  config.vm.provision "shell", inline: $script
end
