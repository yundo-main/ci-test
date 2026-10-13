# 25. 롤백과 배포 승인

운영 환경 배포 전 승인 단계를 두고, 장애 시 이전 revision으로 되돌린다.

```bash
kubectl rollout history deployment/fastcgi-backend
```

Backend Deployment의 revision 목록과 이전 배포 기록을 확인한다.

```bash
kubectl rollout undo deployment/fastcgi-backend
```

승인된 경우 Backend Deployment를 직전 revision으로 되돌린다.

```bash
kubectl rollout status deployment/fastcgi-backend --timeout=180s
```

롤백된 Pod가 준비되어 배포가 완료될 때까지 최대 180초 기다린다.

테스트 네임스페이스에서는 `NAMESPACE=ci-verify bash ./rollback.sh`처럼
지정한다. 승인 프롬프트에 `y`를 입력해야 롤백한다.

- [승인 후 롤백 스크립트](./rollback.sh)

GitHub Actions에서는 `production` Environment에 Required reviewers를 설정하고,
CD 작업의 `environment: production`으로 승인 절차를 연결한다.
