#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

init_postgresql() {
	yum install -y zlib-devel.x86_64 readline-devel.x86_64 gcc.x86_64
	tar -zxvf postgresql-12.*.tar.gz
	mkdir -p /data0/pg_data /data0/pg_build
	cd postgresql-12.*
	./configure --prefix=/data0/pg_build
	make -j4
	make install
	adduser postgres
	chown postgres /data0/pg_data

	# FIXME 运行
	#su - postgres
	#/data0/pg_build/bin/pg_ctl -D /data0/pg_data initdb
	#/data0/pg_build/bin/pg_ctl -D /data0/pg_data -l logfile start

	#sleep 3
	# 关闭
	#/data0/pg_build/bin/pg_ctl -D /data0/pg_data stop -m fast
}

run_postgresql() {
	cat << EOF | tee /etc/systemd/system/postgresql.service
[Unit]
Description=PostgreSQL database server
Documentation=man:postgres(1)
After=network.target

[Service]
Type=forking
User=postgres
OOMScoreAdjust=-1000
Environment=PG_OOM_ADJUST_FILE=/proc/self/oom_score_adj
Environment=PG_OOM_ADJUST_VALUE=0
Environment=PGDATA=/data0/pg_data

ExecStart=/data0/pg_build/bin/pg_ctl start -D \${PGDATA} -w
ExecStop=/data0/pg_build/bin/pg_ctl stop -D \${PGDATA} -m fast
ExecReload=/data0/pg_build/bin/pg_ctl reload -D \${PGDATA}
TimeoutSec=0

[Install]
WantedBy=multi-user.target
EOF

	systemctl start postgresql.service
	systemctl enable postgresql.service
}


init_postgresql
