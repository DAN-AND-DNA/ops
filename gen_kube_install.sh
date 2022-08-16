#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPTS_PATH=$(dirname "${BASH_SOURCE}")
BASE_PATH=$(cd $SCRIPTS_PATH;pwd)
KUBE_DEPS_PATH=${BASE_PATH}/kube_deps


KUBE_PATH=${KUBE_DEPS_PATH}/Kubernetes
KUBE_GIT_URL="https://gitee.com/mirrors/Kubernetes"
KUBE_VERSION="v1.21.3"

CONTAINERD_PATH=${KUBE_DEPS_PATH}/containerdsource
CONTAINERD_GIT_URL="https://gitee.com/mirrors/containerdsource"
CONTAINERD_VERSION="v1.4.4"
CONTAINERD_ARCH=${KUBE_DEPS_PATH}/containerd-1.4.4-linux-amd64

RUNC_PATH=${KUBE_DEPS_PATH}/runc
RUNC_GIT_URL="https://gitee.com/mirrors/runc"
RUNC_VERSION="v1.0.0-rc95"

CRI_TOOLS_PATH=${KUBE_DEPS_PATH}/cri-tools
CRI_TOOLS_GIT_URL="https://github.com/kubernetes-sigs/cri-tools"
CRI_TOOLS_VERSION="v1.20.0"

LIBSECCOMP_PATH=${KUBE_DEPS_PATH}/libseccomp
LIBSECCOMP_GIT_URL="https://gitee.com/mirrors_addons/libseccomp"
LIBSECCOMP_VERSION="v2.3.3"
LIBSECCOMP_OUTPUT=${KUBE_DEPS_PATH}/libseccomp_output

#PACKAGE_NAME=kube_package_${KUBE_VERSION}
PACKAGE_NAME=kube_package
PACKAGE_PATH=${KUBE_DEPS_PATH}/${PACKAGE_NAME}
KUBE_INSTALL_NAME=kube_install_${KUBE_VERSION}
KUBE_INSTALL_PATH=${KUBE_DEPS_PATH}/${KUBE_INSTALL_NAME}

#source ${BASE_PATH}/lib/init_dev_env.sh

clone_src() {
	mkdir -p ${KUBE_DEPS_PATH}
	cd ${KUBE_DEPS_PATH}
	
	if [ ! -d ${KUBE_PATH} ]; then
		git clone ${KUBE_GIT_URL}
	fi

	if [ ! -d ${CONTAINERD_PATH} ]; then
		git clone ${CONTAINERD_GIT_URL}
	fi

	if [ ! -d ${RUNC_PATH} ]; then
		git clone ${RUNC_GIT_URL}
	fi

	if [ ! -d ${CRI_TOOLS_PATH} ]; then
		git clone ${CRI_TOOLS_GIT_URL}
	fi	
	
	if [ ! -d ${LIBSECCOMP_PATH} ]; then
		git clone ${LIBSECCOMP_GIT_URL}
	fi	
	

}


update_src() {
	if [ ! -d ${KUBE_PATH} ]; then
		clone_src
	else 
		cd ${KUBE_PATH}
		git checkout master
		git pull
	fi

	sleep 1
	if [ ! -d ${CONTAINERD_PATH} ]; then
		clone_src
	else
		cd ${CONTAINERD_PATH}
		git checkout master
		git pull 
	fi

	sleep 1
	if [ ! -d ${RUNC_PATH} ]; then
		clone_src
	else 
		cd ${RUNC_PATH}
		git checkout master
		git pull
	fi

	sleep 1
	if [ ! -d ${CRI_TOOLS_PATH} ]; then
		clone_src
	else 
		cd  ${CRI_TOOLS_PATH}
		git checkout master
		git pull
	fi	

	sleep 1
	if [ ! -d ${LIBSECCOMP_PATH} ]; then
		clone_src
	else 
		cd  ${LIBSECCOMP_PATH}
		git checkout master
		git pull
	fi	

}

build_all() {
	#init_dev_env
	go version
        if [ $? -ne 0 ];then
	cat << EOF >> ~/.bash_profile

export PATH=\${PATH}:/usr/local/go/bin
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
export GOPRIVATE=snk.git.node1
export GOINSECURE=snk.git.node1
export GONOSUMDB=snk.git.node1
EOF
        fi

	
	sudo sysctl -w vm.overcommit_memory=0  
	
	cd ${KUBE_PATH}
	git checkout ${KUBE_VERSION}
	make clean
	make kubectl kubelet kubeadm
	

	sudo yum install -y gperf.x86_64 glibc-static.x86_64
	mkdir -p ${LIBSECCOMP_OUTPUT}
	cd ${LIBSECCOMP_PATH}
	git checkout ${LIBSECCOMP_VERSION}
	./autogen.sh
	./configure --prefix=${LIBSECCOMP_OUTPUT}
       	make -j2
        make install
	export PKG_CONFIG_PATH=${LIBSECCOMP_OUTPUT}/lib/pkgconfig
	
	cd ${RUNC_PATH}
	git checkout ${RUNC_VERSION}
	make static BUILDTAGS='seccomp'
	export PKG_CONFIG_PATH=''

	#if [ ! -d ${CONTAINERD_ARCH} ]; then
	#	cd ${CONTAINERD_PATH}
	#	git checkout ${CONTAINERD_VERSION}
	#	make EXTRA_FLAGS="-buildmode pie" EXTRA_LDFLAGS='-linkmode external -extldflags "-fno-PIC -static"' BUILDTAGS="netgo osusergo static_build"
	#fi
	
	cd ${CRI_TOOLS_PATH}
	git checkout ${CRI_TOOLS_VERSION}
	make all

}

fetch_images() {
	# ./kubeadm config images list
	#k8s.gcr.io/kube-apiserver:v1.21.3
	#k8s.gcr.io/kube-controller-manager:v1.21.3
	#k8s.gcr.io/kube-scheduler:v1.21.3
	#k8s.gcr.io/kube-proxy:v1.21.3
	#k8s.gcr.io/pause:3.4.1
	#k8s.gcr.io/etcd:3.4.13-0
	#k8s.gcr.io/coredns/coredns:v1.8.0
	
	sudo docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.21.3
	sleep 1
	sudo docker pull registry.aliyuncs.com/google_containers/kube-controller-manager:v1.21.3
	sleep 1
	sudo docker pull registry.aliyuncs.com/google_containers/kube-scheduler:v1.21.3
	sleep 1
	sudo docker pull registry.aliyuncs.com/google_containers/kube-proxy:v1.21.3
	sleep 1
	sudo docker pull registry.aliyuncs.com/google_containers/pause:3.4.1
	sleep 1
	sudo docker pull registry.aliyuncs.com/google_containers/etcd:3.4.13-0
	sleep 1
	sudo docker pull registry.aliyuncs.com/google_containers/coredns:1.8.0
	sudo docker tag registry.aliyuncs.com/google_containers/coredns:1.8.0 registry.aliyuncs.com/google_containers/coredns:v1.8.0
	sleep 1
	sudo docker pull docker.io/calico/pod2daemon-flexvol:v3.16.10
	sleep 1
        sudo docker pull docker.io/calico/cni:v3.16.10
	sleep 1
        sudo docker pull docker.io/calico/kube-controllers:v3.16.10
	sleep 1
        sudo docker pull docker.io/calico/node:v3.16.10

}



package_all() {
	mkdir -p ${PACKAGE_PATH}
	
	# containerd
	mkdir -p ${PACKAGE_PATH}/containerd/bin
	if [ -d ${CONTAINERD_ARCH} ]; then
		cp -r ${CONTAINERD_ARCH}/containerd* ${PACKAGE_PATH}/containerd/bin/
		# FIXME WHEN NO ARCH DIR
        fi
	cp -r ${RUNC_PATH}/runc ${PACKAGE_PATH}/containerd/bin/
	mkdir -p ${PACKAGE_PATH}/containerd/config
cat << EOF | tee ${PACKAGE_PATH}/containerd/config/config.toml
version = 2
root = "/var/lib/containerd"
state = "/run/containerd"
plugin_dir = ""
disabled_plugins = []
required_plugins = []
oom_score = -999

[grpc]
  address = "/run/containerd/containerd.sock"
  tcp_address = ""
  tcp_tls_cert = ""
  tcp_tls_key = ""
  uid = 0
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216

[ttrpc]
  address = ""
  uid = 0
  gid = 0

[debug]
  address = ""
  uid = 0
  gid = 0
  level = "error"

[metrics]
  address = ""
  grpc_histogram = false

[cgroup]
  path = ""

[timeouts]
  "io.containerd.timeout.shim.cleanup" = "5s"
  "io.containerd.timeout.shim.load" = "5s"
  "io.containerd.timeout.shim.shutdown" = "3s"
  "io.containerd.timeout.task.state" = "2s"

[plugins]
  [plugins."io.containerd.gc.v1.scheduler"]
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = "0s"
    startup_delay = "100ms"
  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    selinux_category_range = 1024
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.4.1"
    stats_collect_period = 10
    systemd_cgroup = false
    enable_tls_streaming = false
    max_container_log_line_size = 16384
    disable_cgroup = false
    disable_apparmor = false
    restrict_oom_score_adj = false
    max_concurrent_downloads = 3
    disable_proc_mount = false
    unset_seccomp_profile = ""
    tolerate_missing_hugetlb_controller = true
    disable_hugetlb_controller = true
    ignore_image_defined_volumes = false
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      default_runtime_name = "runc"
      no_pivot = false
      disable_snapshot_annotations = true
      discard_unpacked_layers = false
      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
        base_runtime_spec = ""
      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
        base_runtime_spec = ""
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          runtime_engine = ""
          runtime_root = ""
          privileged_without_host_devices = false
          base_runtime_spec = ""
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      max_conf_num = 1
      conf_template = ""
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://reg-mirror.qiniu.com", "http://f1361db2.m.daoclound.io", "https://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn", "https://registry.docker-cn.com", "https://registry.aliyuncs.com", "https://registry-1.docker.io"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."harbor.workflow.com:8080"]
          endpoint = ["http://harbor.workflow.com:8080"]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.workflow.com:8080".tls]
          insecure_skip_verify = true
        [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.workflow.com:8080".auth]
          username = "robot\$snk-robot"
          password = "azcj3ul0WTfT41xcaycJvCc5YhEuZoZx"
    [plugins."io.containerd.grpc.v1.cri".image_decryption]
      key_model = ""
    [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""
  [plugins."io.containerd.internal.v1.opt"]
    path = "/opt/containerd"
  [plugins."io.containerd.internal.v1.restart"]
    interval = "10s"
  [plugins."io.containerd.metadata.v1.bolt"]
    content_sharing_policy = "shared"
  [plugins."io.containerd.monitor.v1.cgroups"]
    no_prometheus = false
  [plugins."io.containerd.runtime.v1.linux"]
    shim = "containerd-shim"
    runtime = "runc"
    runtime_root = ""
    no_shim = false
    shim_debug = false
  [plugins."io.containerd.runtime.v2.task"]
    platforms = ["linux/amd64"]
  [plugins."io.containerd.service.v1.diff-service"]
    default = ["walking"]
  [plugins."io.containerd.snapshotter.v1.devmapper"]
    root_path = ""
    pool_name = ""
    base_image_size = ""
    async_remove = false
EOF

cat << EOF | tee ${PACKAGE_PATH}/containerd/config/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF
	# cri-tools
	mkdir -p ${PACKAGE_PATH}/cri_tools/bin
	cp -r  ${CRI_TOOLS_PATH}/_output/crictl ${PACKAGE_PATH}/cri_tools/bin/

	# kube
	mkdir -p ${PACKAGE_PATH}/kube/bin
	cp -f ${KUBE_PATH}/_output/bin/kubectl ${KUBE_PATH}/_output/bin/kubelet ${KUBE_PATH}/_output/bin/kubeadm  ${PACKAGE_PATH}/kube/bin
	mkdir -p ${PACKAGE_PATH}/kube/config
	cat << EOF | tee ${PACKAGE_PATH}/kube/config/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_CONFIG_ARGS \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS
EOF

	cat << EOF | tee ${PACKAGE_PATH}/kube/config/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

	# all base images
	mkdir -p ${PACKAGE_PATH}/images

	sudo docker save -o ${PACKAGE_PATH}/images/pause_3_4_1.image  registry.aliyuncs.com/google_containers/pause:3.4.1
	sudo docker save -o ${PACKAGE_PATH}/images/kube-scheduler_1_21_3.image  registry.aliyuncs.com/google_containers/kube-scheduler:v1.21.3
	sudo docker save -o ${PACKAGE_PATH}/images/kube-proxy_1_21_3.image  registry.aliyuncs.com/google_containers/kube-proxy:v1.21.3
	sudo docker save -o ${PACKAGE_PATH}/images/kube-controller-manager_1_21_3.image  registry.aliyuncs.com/google_containers/kube-controller-manager:v1.21.3
	sudo docker save -o ${PACKAGE_PATH}/images/kube-apiserver_1_21_3.image  registry.aliyuncs.com/google_containers/kube-apiserver:v1.21.3
	sudo docker save -o ${PACKAGE_PATH}/images/etcd_3_4_13_0.image  registry.aliyuncs.com/google_containers/etcd:3.4.13-0
	sudo docker save -o ${PACKAGE_PATH}/images/coredns_1_8_0.image  registry.aliyuncs.com/google_containers/coredns:v1.8.0
	sudo docker save -o ${PACKAGE_PATH}/images/pod2daemon-flexvol_3_16_10.image  docker.io/calico/pod2daemon-flexvol:v3.16.10
	sudo docker save -o ${PACKAGE_PATH}/images/cni_3_16_10.image docker.io/calico/cni:v3.16.10
	sudo docker save -o ${PACKAGE_PATH}/images/kube-controllers_3_16_10.image docker.io/calico/kube-controllers:v3.16.10
	sudo docker save -o ${PACKAGE_PATH}/images/node_3_16_10.image docker.io/calico/node:v3.16.10
	
	cp -r ${CONTAINERD_ARCH}/ctr  ${PACKAGE_PATH}/images/
	sudo chown -R dan:dan ${PACKAGE_PATH}

	mkdir -p  ${KUBE_INSTALL_PATH}
	cp -r ${PACKAGE_PATH} ${KUBE_INSTALL_PATH}/
	
	# 1. kubeadm config print init-defaults
	# 2. wget https://docs.projectcalico.org/archive/v3.15/manifests/calico.yaml
	
	cp -r ${BASE_PATH}/init_default_1_21.yaml.bk ${KUBE_INSTALL_PATH}/init.default.yaml
	cp -r ${BASE_PATH}/calico_3_16_10.yaml.bk ${KUBE_INSTALL_PATH}/calico.yaml
	cp -r ${BASE_PATH}/install.sh ${KUBE_INSTALL_PATH}/install.sh
	cp -r ${BASE_PATH}/lib ${KUBE_INSTALL_PATH}/
	cd ${KUBE_DEPS_PATH}
	tar -czf ${KUBE_INSTALL_NAME}.tar.gz ${KUBE_INSTALL_NAME}
	rm -rf ${KUBE_INSTALL_NAME} ${PACKAGE_NAME}
	
}

#update_src
#build_all
#fetch_images
package_all
