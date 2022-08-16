#!/bin/sh

touch -f /etc/hosts
echo '192.168.0.109 harbor.workflow.com' >> /etc/hosts
/usr/local/bin/dockerd-entrypoint.sh /bin/drone-docker
