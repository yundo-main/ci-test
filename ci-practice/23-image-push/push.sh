#!/usr/bin/env bash
set -euo pipefail
: "${IMAGE_TAG:?set IMAGE_TAG first}"
: "${DOCKER_PAT:?set DOCKER_PAT without committing it}"
echo "$DOCKER_PAT" | docker login --username "${DOCKERHUB_USERNAME:-jarrodkim}" --password-stdin
docker push "${IMAGE_NAME:-jarrodkim/fastapi-backend}:$IMAGE_TAG"
unset DOCKER_PAT

