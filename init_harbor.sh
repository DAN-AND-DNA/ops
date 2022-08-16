#!/bin/bash

# 1. ./install.sh --with-trivy
# 2. docker-compose down
# 3. download trivy-offline.db.tgz
# 4. mkdir -p /data7/harbor_data/trivy-adapter/trivy/db
# 5. chown -R 10000:10000 /data7/harbor_data/trivy-adapter/trivy/db
# 6. mv metadata.json trivy.db  /data7/harbor_data/trivy-adapter/trivy/db/
# 7. docker-compose up -d
