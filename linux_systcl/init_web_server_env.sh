#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail


set_sysctl() {
	cat << EOF | tee /etc/sysctl.d/37-daiyang.conf
# 系统层的文件描述符
fs.file-max=1100000
# 进程层的文件描述符
fs.nr_open=1100000

# 内核从网卡驱动读报文可以继续缓存的数量
net.core.netdev_max_backlog=3000

# 应用可用的端口范围
net.ipv4.ip_local_port_range=1024 65535

# 重用TIME-WAIT
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_tw_recycle=0
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=20

# TIME-WAIT状态的连接上限（主动断开）
net.ipv4.tcp_max_tw_buckets=40000

# syn ack的重试次数（服务器的半连接）
net.ipv4.tcp_synack_retries=3

# syn 的重试次数（客户端）
net.ipv4.tcp_syn_retries=3

# syn 攻击
net.ipv4.tcp_syncookies=1

# 半连接队列长度
net.ipv4.tcp_max_syn_backlog=10000
net.core.somaxconn=10000

# 不使用swap
vm.swappiness=0

EOF

sysctl -p
sysctl --system
}

# 最大1百万个连接来算
set_limit() {
	cat << EOF | tee /etc/security/limits.d/37-daiyang.conf
*    hard nofile 1000000
*    soft nofile 1000000
EOF
	ulimit -a
}

set_system() {
	mkdir -p /etc/systemd/journald.conf.d
	mkdir -p /var/log/journal
	cat << EOF | tee /etc/systemd/journald.conf.d/37-daiyang.conf
[Journal]
Storage=persistent
SystemMaxUse=5G
EOF
	systemctl restart systemd-journald.service
	journalctl --disk-usage

	sed -ri 's/.*swap.*/#&/' /etc/fstab
	swapoff -a
}


set_sysctl
set_limit
set_system
