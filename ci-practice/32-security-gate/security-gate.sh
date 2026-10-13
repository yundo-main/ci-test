#!/usr/bin/env bash
set -euo pipefail

# k8s 독립 저장소의 루트에서 모든 검사 경로를 일관되게 실행한다.
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

# 소스에 토큰·비밀번호가 포함되지 않았는지 먼저 검사한다.
if command -v gitleaks >/dev/null; then
  gitleaks detect --source=. --no-banner --redact
else
  echo "gitleaks is required" >&2
  exit 1
fi

# Python 의존성 취약점 검사
bash practice-order/28-dependency-scan/scan.sh

# 이미지 검사는 빌드·Push된 이미지 주소를 환경변수로 받는다.
if [[ -z "${IMAGE:-}" ]]; then
  echo "IMAGE must be set for image scanning" >&2
  exit 2
fi
bash practice-order/29-image-scan/scan.sh "$IMAGE"
# Kubernetes manifest의 보안 설정 검사
bash practice-order/30-iac-scan/scan.sh
# NetworkPolicy와 RBAC 권한 검증
bash practice-order/31-policy/policy-check.sh

echo "DevSecOps security gate passed"
