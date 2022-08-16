#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set_cpu() {
	for i in `seq 0 100`
        do
                ff="/sys/devices/system/cpu/cpu${i}"
                if [ -d ${ff} ]; then
                        echo ${ff}
                        echo performance > ${ff}/cpufreq/scaling_governor
                else
                        break
                fi
        done
}

set_sysctl() {
	cat << EOF | tee /etc/sysctl.d/30-snk.conf
fs.file-max=9999999
fs.nr_open=9999999

net.core.netdev_max_backlog=20480
net.core.rmem_max=16777216 
net.core.wmem_max=16777216
net.core.somaxconn=65535

net.ipv4.ip_local_port_range=1024 65535
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=20
net.ipv4.tcp_no_metrics=1
net.ipv4.tcp_max_tw_buckets=400000
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_keepalive_time=30
net.ipv4.tcp_syncookies=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.tcp_max_syn_backlog=20480
net.ipv4.ip_forward=0
net.ipv4.conf.default.accept_source_route=0

vm.min_free_kbytes=131072
vm.overcommit_memory=2
vm.overcommit_ratio=87
vm.vfs_cache_pressure=100
vm.swappiness=0
vm.dirty_background_ratio=4
vm.dirty_ratio=6

kernel.msgmnb=65536
kernel.msgmax=65536
kernel.msgmni=2048

vm.nr_hugepages=0
EOF

sysctl -p
sysctl --system
}

set_limit() {
	cat << EOF | tee /etc/security/limits.d/30-snk.conf
*    hard nofile 9999999
*    soft nofile 9999999
*    hard memlock 4194304
*    soft memlock 4194304
*    hard nproc 100000
*    soft nproc 100000
dan  hard nofile 9999
dan  soft nofile 9999
root hard nofile 9999
root soft nofile 9999
EOF
}

set_system() {
	yum upgrade -y

	systemctl stop firewalld
	systemctl disable firewalld
	setenforce 0;
	sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config;
	swapoff -a
	sed -ri 's/.*swap.*/#&/' /etc/fstab
	
	## log
	mkdir -p /etc/systemd/journald.conf.d
	mkdir -p /var/log/journal
	cat << EOF | tee /etc/systemd/journald.conf.d/30-snk.conf
[Journal]
Storage=persistent
SystemMaxUse=10G
EOF
	systemctl restart systemd-journald.service
	journalctl --disk-usage
	
	## time
	yum install -y chrony.x86_64
	cat << EOF | tee /etc/chrony.conf
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
server 192.168.0.245 iburst

driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
allow 192.168.0.0/16
logdir /var/log/chrony
EOF
	
	systemctl daemon-reload
	systemctl restart chronyd
	systemctl enable chronyd
}

set_hugepages() {
	# 1. id postgres
	# 2. just for share buffers: 20G/1G=20 + 1 # 21G pre alloc
	# 3. append GRUB_CMDLINE_LINUX="...... transparent_hugepage=never hugepagesz=1GB hugepages=21 default_hugepagesz=1GB" of /etc/default/grub
	# 4. grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg or grub2-mkconfig -o /boot/grub2/grub.cfg
	# 5. shutdown -r now
}

#set_cpu
set_sysctl
#set_limit
#set_system
