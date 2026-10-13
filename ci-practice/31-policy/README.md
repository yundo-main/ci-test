# 31. Kubernetes 정책 검증

- [정책 검증 스크립트](./policy-check.sh)

NetworkPolicy와 RBAC가 3-Tier 구성에 적용되었는지 확인한다.

```bash
kubectl apply --dry-run=server \
  -f practice-order/12-networkpolicy/3tier-networkpolicy.yml
```

NetworkPolicy manifest를 실제로 변경하지 않고 API Server 검증만 수행한다.

```bash
kubectl auth can-i get services \
  --as=system:serviceaccount:default:fastcgi-backend
```

Backend ServiceAccount가 현재 Namespace의 Service 조회 권한을 가지는지 확인한다.

클러스터 정책 엔진을 도입할 때는 Kyverno 또는 OPA Gatekeeper로 이미지 출처,
privileged 컨테이너, 필수 보안 설정을 강제할 수 있다.
