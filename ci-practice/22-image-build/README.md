# 22. Docker 이미지 빌드·태그

애플리케이션 소스의 변경 이력을 이미지 태그에 반영한다.

- [Dockerfile](./backend/Dockerfile)
- [FastAPI 코드](./backend/main.py)
- [Python 의존성](./backend/requirements.txt)

```bash
export IMAGE_TAG="$(git rev-parse --short HEAD)"
```

현재 Git commit의 짧은 SHA를 이미지 태그로 지정한다.

```bash
docker build -t jarrodkim/fastapi-backend:"$IMAGE_TAG" \
  practice-order/22-image-build/backend
```

Backend Dockerfile과 소스를 사용해 태그가 지정된 이미지를 빌드한다.

```bash
docker image inspect jarrodkim/fastapi-backend:"$IMAGE_TAG"
```

빌드된 이미지의 태그, 아키텍처와 설정을 확인한다.

`latest`만 사용하면 어떤 소스가 배포되었는지 추적하기 어렵다. 학습 후에는
Commit SHA 또는 릴리스 버전 태그를 함께 사용한다.
