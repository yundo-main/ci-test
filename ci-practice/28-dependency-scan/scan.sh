#!/usr/bin/env bash
set -euo pipefail

# 인자를 생략하면 22번에서 만든 실습용 requirements.txt를 검사한다.
repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"
requirements="${1:-practice-order/22-image-build/backend/requirements.txt}"
# pip-audit는 설치되어 있어야 하며, 취약점 발견 시 비정상 종료한다.
command -v python3 >/dev/null
command -v pip-audit >/dev/null
pip-audit -r "$requirements"
