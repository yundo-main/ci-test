#!/usr/bin/env bash
set -euo pipefail

# 기본 검사 대상은 3-Tier manifest 디렉터리다.
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"
target="${1:-practice-order/10-3tier}"
command -v checkov >/dev/null
# Kubernetes 보안 설정과 위험한 manifest 패턴을 검사한다.
checkov -d "$target" --framework kubernetes
