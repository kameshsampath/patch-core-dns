#!/bin/bash
# A script that wil be used to patch the core dns aliases
# e.g say i want dev.local to be mapped to default registry registry.kube-system.cluster.svc.local
#
set -eu

set -o pipefail 

docker build -t quay.io/rhdevelopers/core-dns-patcher .

docker tag quay.io/rhdevelopers/core-dns-patcher quay.io/rhdevelopers/core-dns-patcher:0.0.2

docker push quay.io/rhdevelopers/core-dns-patcher
docker push quay.io/rhdevelopers/core-dns-patcher:0.0.2