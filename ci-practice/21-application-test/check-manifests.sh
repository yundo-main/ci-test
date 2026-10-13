#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

manifests=(
  ci-practice/10-3tier/frontend.yml
  ci-practice/10-3tier/backend.yml
  ci-practice/11-ingress/ingress.yml
)

if ! command -v kubeconform >/dev/null 2>&1; then
  echo "kubeconform이 필요합니다. 먼저 kubeconform을 설치하세요." >&2
  exit 1
fi

kubeconform -strict -summary "${manifests[@]}"
