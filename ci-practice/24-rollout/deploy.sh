#!/usr/bin/env bash
set -euo pipefail
IMAGE="${1:?usage: deploy.sh IMAGE:TAG}"
NAMESPACE="${NAMESPACE:-default}"
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"
kubectl -n "$NAMESPACE" apply -f practice-order/10-3tier/frontend.yml
kubectl -n "$NAMESPACE" apply -f practice-order/10-3tier/backend.yml
kubectl -n "$NAMESPACE" set image deployment/fastcgi-backend backend="$IMAGE"
kubectl -n "$NAMESPACE" rollout status deployment/fastcgi-backend --timeout=180s
