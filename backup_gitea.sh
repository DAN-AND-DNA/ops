#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

GITEA_PATH=$(dirname "${BASH_SOURCE}")

mkdir -p ${GITEA_PATH}/bk

/data7/git/gitea dump --config /data7/git/config/app.ini

mv gitea-dump-*.zip  ${GITEA_PATH}/bk/

cp /etc/systemd/system/gitea.service ${GITEA_PATH}/bk/
