# 29. 컨테이너 이미지 검사

- [이미지 검사 스크립트](./scan.sh)

빌드한 이미지의 OS 패키지와 애플리케이션 의존성을 Trivy로 검사한다.

```bash
export IMAGE_TAG="$(git rev-parse --short HEAD)"
trivy image --severity HIGH,CRITICAL --exit-code 1 \
  jarrodkim/fastapi-backend:"$IMAGE_TAG"
```

학습 단계에서는 `HIGH,CRITICAL`부터 차단하고, 운영 기준에 맞춰 예외와 기준을
별도 관리한다.
