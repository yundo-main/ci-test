# 30. Kubernetes 설정 검사

- [IaC 검사 스크립트](./scan.sh)

Kubernetes YAML의 권한, 보안 컨텍스트, Secret 노출과 같은 위험 설정을
배포 전에 검사한다.

```bash
docker run --rm -v "$PWD:/src" bridgecrew/checkov:latest \
  -d /src/practice-order/10-3tier
```

실제 CI에서는 검사 대상 디렉터리와 허용 예외를 저장소 기준에 맞게 지정한다.
