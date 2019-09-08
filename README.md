# prerequisite

* vagrant
* box file or the ability to access the box office site
* providers(I use kvm, others are OK)

# quick start of k8s with vagrant

## step one (optional)
uncomment modify docker regietry setting in  Vagrantfile, replace the *** with your mirror id:
``` bash
sudo cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://***.mirror.aliyuncs.com"]
}
EOF
```

## step two: prepare the env
``` bash
./start.sh
```

## step three: init k8s on master node
``` bash
# enter k8s master node
$vagrant ssh k8s-master
# set the swap on ==false
echo "KUBELET_EXTRA_ARGS=--fail-swap-on=false" > /etc/sysconfig/kubelet 
# init
$kubeadm init --kubernetes-version=v1.15.3 --service-cidr=10.96.0.0/12 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Swap
## now we can get the command to join the cluster, save it for furthur use
$mkdir -p $HOME/.kube
$sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$sudo chown $(id -u):$(id -g) $HOME/.kube/config
# install flannel
$kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```
## step four: worker node join the cluster
``` bash
$echo "KUBELET_EXTRA_ARGS=--fail-swap-on=false" > /etc/sysconfig/kubelet 

# this command comes after kubadm init command, every cluster has different token and sha256
$kubeadm join 172.28.128.35:6443 --token jr158s.0l4u99eyhe4m17sv \
    --discovery-token-ca-cert-hash sha256:781ddd9b27ecbfc0628cecd22094721471b5838199c1820f61a47af01af10f4f \
    --ignore-preflight-errors=Swap
```


# limitation
current only one k8s master node and two worker nodes. If more k8s master wanted, it needs more work.

# implementation

1. download the box file and add it locally, if you don't have the ability to access it with internet
2. prerequisite for k8s nodes, including: bridge setting, disable firewall, disable selinux, install docker, set docker
3. install kubelet, kubeadmin, kubectl on every node
4. pull the essential images of kubeadm from mirrors urls and tag them to orignal name
5.  