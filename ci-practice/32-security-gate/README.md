# 32. DevSecOps 보안 게이트

- [통합 보안 게이트 스크립트](./security-gate.sh)

앞 단계의 검사를 CI 파이프라인에 연결하고, 기준을 통과하지 못하면 이미지
Push와 Kubernetes 배포를 중단한다.

```yaml
- name: Secret scan
  run: gitleaks detect --source=. --no-banner --redact

- name: Dependency scan
  run: pip-audit -r practice-order/22-image-build/backend/requirements.txt

- name: Image scan
  run: trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE"
```

최종 배포 단계는 20번 CD보다 뒤에 실행한다. 보안 검사를 우회하기 위해
`--exit-code 0`으로 변경하지 않으며, 예외는 검토 가능한 파일로 관리한다.
