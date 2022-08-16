#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

install_kube() {
	BASE_PATH=$(dirname "${BASH_SOURCE}")
        PACKAGE_PATH=$BASE_PATH/../kube_package
        chmod +x ${PACKAGE_PATH}/kube/bin/*
        cp -f ${PACKAGE_PATH}/kube/bin/* /usr/bin/

	mkdir -p /usr/lib/systemd/system/kubelet.service.d
        cp -f ${PACKAGE_PATH}/kube/config/kubelet.service /usr/lib/systemd/system/kubelet.service
        cp -f ${PACKAGE_PATH}/kube/config/10-kubeadm.conf /usr/lib/systemd/system/kubelet.service.d/
	
        systemctl daemon-reload
	systemctl enable kubelet
	systemctl start kubelet
}
