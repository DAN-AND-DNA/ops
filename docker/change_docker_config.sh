#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# 1. change the default storage path (修改默认存储位置)
# 2. export the external tcp api entry (暴露对外tcp api入口)
init_docker() {
        sudo mkdir -p /etc/docker
        sudo cat << EOF | sudo tee /etc/docker/daemon.json
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
        "graph": "/home/dan/data/docker_runtime",
        "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"]
}
EOF

        sudo mkdir -p /etc/systemd/system/docker.service.d
        sudo cat << EOF | sudo tee /etc/systemd/system/docker.service.d/docker.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF

        sudo systemctl daemon-reload
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo systemctl enable containerd.service
}

init_docker
