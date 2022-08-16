#!/bin/bash

#  -e DRONE_RUNNER_CLONE_IMAGE=drone/git:dan2 \

docker run -d \
  --add-host=harbor.workflow.com:192.168.0.109 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/localtime:/etc/localtime \
  -e DRONE_RPC_PROTO=http \
  -e DRONE_RPC_HOST=192.168.0.109:3002 \
  -e DRONE_RPC_SECRET=bea26a2221fd8090ea38720fc445eca6 \
  -e DRONE_RUNNER_CAPACITY=10 \
  -e DRONE_RUNNER_NETWORKS=dan_network \
  -e DRONE_RUNNER_CLONE_IMAGE=harbor.workflow.com:3001/drone-snk/git:latest \
  -e DRONE_RUNNER_PRIVILEGED_IMAGES=harbor.workflow.com:3001/plugins-snk/docker \
  --network dan_network \
  -p 3003:3000 \
  --restart always \
  --name runner \
  harbor.workflow.com:3001/drone-snk/drone-runner-docker:1.6.3

#-e DRONE_RUNNER_CLONE_IMAGE=drone/git:dan2 \
