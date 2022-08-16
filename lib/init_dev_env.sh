#!/bin/bash

init_dev_env() {
	/usr/local/go/bin/go version
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
}

