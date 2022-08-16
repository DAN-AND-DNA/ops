#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set_systemd() {
        mkdir -p /data/heartbeat-dns/work_dir
        chown -R 0cd26bd1ff00106f1febc01bd60f67c8:0cd26bd1ff00106f1febc01bd60f67c8 /data/heartbeat-dns/work_dir
        cat << EOF | tee /etc/systemd/system/heartbeat-dns.service
[Unit]
Description=Heartbeat dns service
After=syslog.target
After=network.target

[Service]
Type=simple
User=0cd26bd1ff00106f1febc01bd60f67c8
Group=0cd26bd1ff00106f1febc01bd60f67c8
WorkingDirectory=/data/heartbeat-dns/work_dir
ExecStart=/data/heartbeat-dns/heartbeat-dns --run-as=production --rpc-listen-port=3737 --rpc-salt=_bigsnk-2021_ --rpc-key=_big2021-snk===  --rpc-idle=10
ExecReload=/bin/kill -15 \$MAINPID
ExecStop=/bin/kill -15 \$MAINPID
KillMode=process
KillSignal=SIGTERM
TimeoutSec=20

RestartSec=2s
Restart=always

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl restart heartbeat-dns
        systemctl enable heartbeat-dns
}

set_systemd
