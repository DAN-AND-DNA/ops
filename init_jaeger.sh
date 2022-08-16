#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

init_jaeger() {
	docker run -d --restart always --name jaeger \
	-e LOG_LEVEL=error \
  	-p 5775:5775/udp \
  	-p 6831:6831/udp \
  	-p 6832:6832/udp \
  	-p 5778:5778 \
  	-p 16686:16686 \
  	-p 14268:14268 \
  	-p 14250:14250 \
  	jaegertracing/all-in-one:1.23
}


init_jaeger
