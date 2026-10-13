# PodDisruptionBudget

자발적 중단 상황에서 유지해야 하는 최소 Pod 수 또는 비율을 정의한다.

## Backend 예제

[`backend-pdb.yml`](./backend-pdb.yml)은 기존 3-Tier Backend의 Pod가 자발적
중단 상황에서도 최소 1개 유지되도록 한다.

```bash
kubectl apply -f backend-pdb.yml
```

Backend의 자발적 중단을 보호하는 PodDisruptionBudget을 생성한다.

```bash
kubectl get pdb fastcgi-backend-pdb
```

PDB의 최소 가용 Pod 수와 현재 허용 중단 수를 요약해 확인한다.

```bash
kubectl describe pdb fastcgi-backend-pdb
```

PDB selector, 조건, 이벤트를 상세 확인한다.
