#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail


ck() {
	# install

        yum install -y yum-utils
        rpm --import https://repo.clickhouse.tech/CLICKHOUSE-KEY.GPG
        yum-config-manager --add-repo https://repo.clickhouse.tech/rpm/stable/x86_64
        yum install -y clickhouse-server.noarch clickhouse-client.noarch
	mkdir -p /data2/clickhouse /data2/clickhouse-log
	chown -R clickhouse:clickhouse /data2/clickhouse
	chown -R clickhouse:clickhouse /data2/clickhouse-log

	# add config to config.d

	cat << EOF | tee /etc/clickhouse-server/config.d/30-snk.xml
<?xml version="1.0"?>
<yandex>
	<logger>
		<level>trace</level>
		<log>/data2/clickhouse-log/clickhouse-server.log</log>
		<errorlog>/data2/clickhouse-log/clickhouse-server.err.log</errorlog>
		<size>1000M</size>
		<count>10</count>
	</logger>
	<path>/data2/clickhouse/</path>
	<tmp_path>/data2/clickhouse/tmp/</tmp_path>
	<user_files_path>/data2/clickhouse/user_files/</user_files_path>
	<user_directories>
		<users_xml>
			<path>users.xml</path>
		</users_xml>
		<local_directory>
			<path>/data2/clickhouse/access</path>
		</local_directory>
	</user_directories>
    	<top_level_domains_path>/data2/clickhouse/top_level_domains/</top_level_domains_path>
    	<format_schema_path>/data2/clickhouse/format_schemas/</format_schema_path>
	<max_server_memory_usage_to_ram_ratio>0.7</max_server_memory_usage_to_ram_ratio>

	<listen_host>::</listen_host>
	<listen_try>1</listen_try>
</yandex>
EOF

	# add config to users.d

	cat << EOF | tee /etc/clickhouse-server/users.d/30-snk.xml
<?xml version="1.0"?>
<yandex>
	<profiles>	
		<default>
			<max_memory_usage>12000000000</max_memory_usage>
			<max_bytes_before_external_group_by>6000000000</max_bytes_before_external_group_by>
            		<max_bytes_before_external_sort>6000000000</max_bytes_before_external_sort>
			<join_use_nulls>1</join_use_nulls>
		</default>
	</profiles>
</yandex>
EOF

	systemctl start clickhouse-server
	systemctl enable clickhouse-server
}

ck
