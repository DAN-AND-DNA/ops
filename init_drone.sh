#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

DRONE_RPC_SECRET_VAL=bea26a2221fd8090ea38720fc445eca6

docker run \
  --add-host=gitea.workflow.com:192.168.0.109 \
  --volume=/data7/drone:/data \
  --volume=/etc/localtime:/etc/localtime \
  --env=DRONE_DEBUG=true \
  --env=DRONE_GITEA_SERVER=http://gitea.workflow.com:3000 \
  --env=DRONE_GITEA_CLIENT_ID=5029c5c5-2cd7-4f02-b49e-9b51154949b5 \
  --env=DRONE_GITEA_CLIENT_SECRET=v3SJQIxCFcLd4UpmahvrChMuxBxLFk7FM3_8N6iwtYM= \
  --env=DRONE_RPC_SECRET=${DRONE_RPC_SECRET_VAL} \
  --env=DRONE_SERVER_HOST=drone.workflow.com:3002 \
  --env=DRONE_SERVER_PROTO=http \
  --env=DRONE_RUNNER_CLONE_IMAGE=harbor.workflow.com:3001/drone-snk/git:latest \
  --publish=3002:80 \
  --publish=8443:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  harbor.workflow.com:3001/drone-snk/drone:1.10.1

