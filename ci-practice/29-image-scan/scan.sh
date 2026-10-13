#!/usr/bin/env bash
set -euo pipefail

# 검사 대상은 반드시 IMAGE:TAG 형식으로 전달한다.
image="${1:-}"
if [[ -z "$image" ]]; then
  echo "usage: $0 IMAGE:TAG" >&2
  exit 2
fi

command -v trivy >/dev/null
# HIGH 또는 CRITICAL 취약점이 발견되면 CI 단계가 실패한다.
trivy image --severity HIGH,CRITICAL --exit-code 1 "$image"
