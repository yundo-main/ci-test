# 26. GitOps 확장

CI는 이미지와 manifest를 검증하고, CD 또는 GitOps Controller가 클러스터
상태를 동기화하도록 확장한다.

권장 흐름:

```text
소스 변경 → CI 검증 → 이미지 Push → 배포 저장소의 이미지 태그 변경
→ GitOps Controller 동기화 → Rollout 확인
```

- [Kustomize 배포 정의](./kustomization.yaml)

현재 학습 저장소는 기존 `10-3tier`, `11-ingress` 매니페스트를 단일 소스 오브
트루스로 유지하므로, Kustomize의 외부 경로 제한을 해제해 빌드한다.

```bash
kubectl kustomize practice-order/26-gitops \
  --load-restrictor=LoadRestrictionsNone
```

운영 GitOps 저장소로 분리할 때는 매니페스트를 같은 Kustomize 트리 아래로
복사하거나 별도 배포 저장소로 이동하고, 이 옵션을 제거한다.

이 단계에서는 기존 `10-3tier`, `11-ingress` manifest를 배포 저장소로 분리할
수 있다. Argo CD나 Flux를 도입할 때도 Secret과 kubeconfig는 저장소에
커밋하지 않는다.
