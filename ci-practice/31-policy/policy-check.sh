#!/usr/bin/env bash
set -euo pipefail

# NetworkPolicy manifest가 현재 클러스터 API 규격에 맞는지 확인한다.
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"
manifest="practice-order/12-networkpolicy/3tier-networkpolicy.yml"
kubectl apply --dry-run=server -f "$manifest"
# Backend ServiceAccount가 필요한 서비스 조회 권한을 갖는지 확인한다.
kubectl auth can-i get services \
  --as=system:serviceaccount:default:fastcgi-backend
# Secret을 읽을 수 없어야 한다. 'yes'이면 최소 권한 원칙 위반으로 실패한다.
if [[ "$(kubectl auth can-i get secrets \
  --as=system:serviceaccount:default:fastcgi-backend)" == "yes" ]]; then
  echo "security policy failed: backend can read secrets" >&2
  exit 1
fi
