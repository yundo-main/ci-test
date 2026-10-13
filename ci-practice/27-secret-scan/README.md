# 27. Secret 탐지

소스 코드와 커밋에 비밀번호, 토큰, kubeconfig가 포함되지 않았는지 검사한다.

```bash
docker run --rm -v "$PWD:/repo" zricethezav/gitleaks:latest \
  detect --source=/repo --no-banner
```

실습 저장소에는 실제 Secret 값을 저장하지 않는다. 오탐은 별도 설정 파일로
관리하고, 유효한 토큰이 발견되면 즉시 폐기하고 새 토큰을 발급한다.

