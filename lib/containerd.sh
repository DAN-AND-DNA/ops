#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail


install_containerd() {

	BASE_PATH=$(dirname "${BASH_SOURCE}")
	PACKAGE_PATH=${BASE_PATH}/../kube_package
	chmod +x ${PACKAGE_PATH}/containerd/bin/*
	cp -f ${PACKAGE_PATH}/containerd/bin/* /usr/bin/
	cp -f ${PACKAGE_PATH}/cri_tools/bin/* /usr/bin/

	mkdir -p /etc/containerd
	cp -f ${PACKAGE_PATH}/containerd/config/config.toml /etc/containerd/
	cp -f ${PACKAGE_PATH}/containerd/config/containerd.service /usr/lib/systemd/system/containerd.service
	
	systemctl daemon-reload
	systemctl enable containerd	
	systemctl restart containerd

	crictl config runtime-endpoint unix:///run/containerd/containerd.sock
}

install_images() {

	BASE_PATH=$(dirname "${BASH_SOURCE}")
	PACKAGE_PATH=${BASE_PATH}/../kube_package
	IMGS=${PACKAGE_PATH}/images
	CTR=${IMGS}/ctr

	for IMG in ${IMGS}/*.image; do
    		echo ${IMG}
		${CTR} --namespace "k8s.io" images import ${IMG}

	done
}
