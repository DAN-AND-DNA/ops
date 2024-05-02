#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

install_docker_ubuntu() {
        sudo apt-get update
        sudo apt-get install ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg


        sudo echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        sudo usermod -aG docker $USER


        sudo mkdir -p /etc/docker

        sudo cat << EOF | sudo tee /etc/docker/daemon.json

{
        "storage-driver": "overlay2",
        "registry-mirrors" : ["https://reg-mirror.qiniu.com", "http://f1361db2.m.daoclound.io", "https://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn", "https://registry.docker-cn.com"],
        "insecure-registries" : ["harbor.workflow.com:3001"],
        "default-ulimits": {
                "nofile": {
                        "Name": "nofile",
                        "Hard": 1000000,
                        "Soft": 1000000
                }
        }
}
EOF
        sudo systemctl daemon-reload
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo systemctl enable containerd.service
}

install_docker_centos() {
        sudo yum install -y yum-utils
        sudo yum-config-manager \
        --add-repo \
        http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

        sudo yum install -y docker-ce docker-ce-cli containerd.io

        sudo mkdir -p /etc/docker
        sudo cat << EOF | sudo tee /etc/docker/daemon.json
{
        "storage-driver": "overlay2",
        "registry-mirrors" : ["https://reg-mirror.qiniu.com", "http://f1361db2.m.daoclound.io", "https://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn", "https://registry.docker-cn.com"],
        "insecure-registries" : ["harbor.workflow.com:3001"],
        "default-ulimits": {
                "nofile": {
                        "Name": "nofile",
                        "Hard": 1000000,
                        "Soft": 1000000
                }
        }
}
EOF
        sudo systemctl daemon-reload
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo systemctl enable containerd.service
}



apt-get --help >/dev/null 2>&1
if [ $? -eq 0 ]; then
	install_docker_ubuntu
else
	install_docker_centos
fi
