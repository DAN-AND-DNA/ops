#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

GITEA_PATH=$(dirname "${BASH_SOURCE}")

echo "unzip"
echo "mkdir -p config; mv app.ini ./config/"
echo "mv repos ./data/gitea-repositories"
echo "sqlite3 \$DATABASE_PATH < ./gitea-db.sql"
echo "systemctl restart gitea"
