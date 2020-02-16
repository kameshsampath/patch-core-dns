#!/bin/bash
# A script that wil be used to patch the core dns aliases
# e.g say i want dev.local to be mapped to default registry registry.kube-system.cluster.svc.local
#
set -eu

set -o pipefail 

shopt -s expand_aliases

KUBECTL_CMD=$(find /var/lib/minikube/binaries -name kubectl)
echo "Using $KUBECTL_CMD"

alias kubectl="$KUBECTL_CMD"

kubectl version
