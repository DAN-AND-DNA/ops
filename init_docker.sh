#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

init_docker() {
        yum install -y yum-utils
        yum-config-manager \
        --add-repo \
        http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

        yum install -y docker-ce docker-ce-cli containerd.io

        mkdir -p /etc/docker
        cat << EOF | tee /etc/docker/daemon.json
{
        "storage-driver": "overlay2",
        "registry-mirrors" : ["https://reg-mirror.qiniu.com", "http://f1361db2.m.daoclound.io", "https://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn", "https://registry.docker-cn.com"],
        "insecure-registries" : ["harbor.workflow.com:3001"],
        "default-ulimits": {
                "nofile": {
                        "Name": "nofile",
                        "Hard": 300001,
                        "Soft": 300000
                }
        },
        "graph": "/data/docker_runtime"
}
EOF

        systemctl start docker
        systemctl enable docker
        systemctl enable containerd.service
}

init_docker
