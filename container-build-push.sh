#!/bin/bash
# A script that wil be used to patch the core dns aliases
# e.g say i want dev.local to be mapped to default registry registry.kube-system.cluster.svc.local
#
set -eu

set -o pipefail 

DRONE_TAG=${DRONE_TAG:-$(svu patch)}
DEST_IMAGE=${DEST_IMAGE:-kameshsampath/patch-core-dns}

docker buildx inspect "$BUILDER" || \
   docker buildx create --name="$BUILDER" \
   --driver=docker-container --driver-opt=network=host

docker buildx build --push --builder="$BUILDER" \
        --platform=linux/amd64,linux/arm64 --build-arg \ --tag="$DEST_IMAGE:$DRONE_TAG" \
        --tag="$DEST_IMAGE:latest"  .

# drone exec --secret-file="${SECRET_FILE}" --env-file="${ENV_FILE}" --trusted .drone.local.yml