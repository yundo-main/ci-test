# 23. Docker Hub Push

빌드한 이미지를 Docker Hub에 Push한다.

```bash
read -s DOCKER_PAT
echo
```

`read`로 Docker Hub PAT를 입력받고, `echo`로 입력 줄을 종료한다. PAT는 화면에
표시되지 않는다.

```bash
echo "$DOCKER_PAT" | docker login --username jarrodkim --password-stdin
```

PAT를 표준 입력으로 전달해 Docker Hub에 로그인한다.

```bash
docker push jarrodkim/fastapi-backend:"$IMAGE_TAG"
```

지정한 이미지 태그를 Docker Hub에 업로드한다.

```bash
unset DOCKER_PAT
```

터미널에서 PAT 환경변수를 제거한다.

- [Push 스크립트](./push.sh)

토큰은 명령이나 YAML에 직접 저장하지 않는다. GitHub Actions에서는
`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` Secrets를 사용한다.
