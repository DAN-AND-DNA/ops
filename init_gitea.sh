#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set_systemd() {
	useradd git
	mkdir -p /data7/git/work_dir
	chown -R git:git /data7/git
	yum install -y git
	cat << EOF | tee /etc/systemd/system/gitea.service
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target

[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/data7/git/work_dir
ExecStart=/data7/git/gitea web --config /data7/git/config/app.ini
Restart=always

[Install]
WantedBy=multi-user.target
EOF
	systemctl daemon-reload
	systemctl restart gitea
	systemctl enable gitea
}

set_systemd
