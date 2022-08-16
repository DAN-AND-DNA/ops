#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail


drilling-cat() {
        cat << EOF | tee /etc/systemd/system/drilling-cat.service
[Unit]
Description=Drilling-cat log service
After=syslog.target
After=network.target

[Service]
RestartSec=2s
Type=simple
User=dan
Group=dan
WorkingDirectory=/data2/drilling-cat/work-dir
ExecStart=/data2/drilling-cat/drilling-cat --run-as=production --db-clickhouse-dns=tcp://log.ck-01.com:9000?debug=false&compress=1&read_timeout=30&write_timeout=30 --http-header-name=YunfanAPI --http-listen-port=37000 --http-read-timeout-secs=10 --http-body-limit-bytes=1048576 
ExecReload=/bin/kill -15 \$MAINPID
ExecStop=/bin/kill -15 \$MAINPID
KillMode=process
KillSignal=SIGTERM
TimeoutSec=20

Restart=always

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl restart drilling-cat
        systemctl enable drilling-cat
}

drilling-cat
