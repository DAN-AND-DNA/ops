#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

CLUSTER_CIDR=${CLUSTER_CIDR:-"10.244.0.0/16"}

K8S_PATH=$(dirname "${BASH_SOURCE}")
K8S_LIB_PATH=${K8S_PATH}/lib
source ${K8S_LIB_PATH}/containerd.sh
source ${K8S_LIB_PATH}/kube.sh


setup_container_runtime() {
	modprobe overlay
	modprobe br_netfilter
        modprobe ip_vs 
	modprobe ip_vs_rr 
	modprobe ip_vs_wrr 
	modprobe ip_vs_sh 
	modprobe nf_conntrack_ipv4 
	cat << EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
EOF
	yum install -y ipvsadm
	
	cat <<EOF | tee /etc/sysctl.d/40-k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
	sysctl --system
	
	install_containerd
	install_images
}

setup_kubelet() {
	setenforce 0
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	install_kube
}

setup_master() {
	yum install -y socat conntrack-tools.x86_64
	kubeadm init --config=init.default.yaml 

	#kubectl taint nodes --all node-role.kubernetes.io/master-

	# see https://kubernetes.io/docs/admin/kubelet-tls-bootstrapping/
    	#if [ $(kubectl get csr | awk '/^csr/{print $1}' | wc -l) -gt 0 ]; then
	#	kubectl certificate approve $(kubectl get csr | awk '/^csr/{print $1}')
 	#fi  
}

setup_cni() {
	kubectl apply -f ./calico.yaml
}

join_node() {
	mkdir -p /etc/kubernetes/manifests
}


#rm_node() {
	# XXX AS master01.com
	# kubectl drain worker01.com --delete-local-data --force --ignore-daemonsets
	
	# XXX AS worker01.com
	# ipvsadm --clean
	# rm -rf /etc/cni/net.d
	# kubeadm reset
	
	# XXX AS master01.com
	# kubectl delete node worker01.com
#}

setup_container_runtime
setup_kubelet
setup_master
setup_cni
