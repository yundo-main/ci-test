#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-default}"
kubectl -n "$NAMESPACE" rollout history deployment/fastcgi-backend
read -r -p "Rollback fastcgi-backend? [y/N] " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
  kubectl -n "$NAMESPACE" rollout undo deployment/fastcgi-backend
  kubectl -n "$NAMESPACE" rollout status deployment/fastcgi-backend --timeout=180s
fi
