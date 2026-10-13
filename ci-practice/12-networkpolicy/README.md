# NetworkPolicy

Pod 간 ingress·egress 네트워크 허용 규칙을 정의한다. CNI가 NetworkPolicy를
지원해야 실제로 적용된다.

![3-Tier NetworkPolicy 허용 흐름](./networkpolicy-overview.svg)

현재 클러스터는 Calico CNI를 사용하므로 Kubernetes 표준 NetworkPolicy를
적용한다. NetworkPolicy의 목적은 3-Tier 구성 요소 사이의 통신을 보호하고
허용된 경로만 명시적으로 관리하는 것이다. 정책에 포함되지 않은 통신은
제한된다.

정책 대상은 기존 10단계 3-Tier의 `frontend`, `fastcgi-backend`, `mariadb`
Pod이며, 별도의 애플리케이션을 생성하지 않는다.

## 3-Tier 정책

[`3tier-networkpolicy.yml`](./3tier-networkpolicy.yml)은 다음 보호 경로를
명시한다.

```text
Ingress Controller → Frontend:80
Frontend → Backend:8000
Backend → MariaDB:3306
Frontend·Backend → kube-dns:53
Backup Job → MariaDB:3306
Operational Backend → 외부 HTTPS:443 및 kube-dns:53
```

13번 `backend-operational.yml`은 시작할 때 PyPI에서 패키지를 설치하므로
실습용으로 외부 HTTPS egress를 허용한다. 운영 환경에서는 의존성을 이미지에
미리 포함하고 이 예외를 제거하는 편이 안전하다.

15번 Backup Job은 `app: mariadb-backup` 라벨을 사용하며, MariaDB로의 덤프
통신만 허용한다.

정책 대상은 `app` 라벨이 `frontend`, `fastcgi-backend`, `mariadb`인 Pod다.

## 적용 순서

10단계 3-Tier와 11단계 Ingress가 정상 동작하는지 먼저 확인한 뒤 적용한다.

```bash
kubectl apply -f 3tier-networkpolicy.yml
```

3-Tier Pod 간 허용 ingress·egress 규칙을 적용한다.

```bash
kubectl get networkpolicy
```

현재 Namespace에 생성된 NetworkPolicy 목록을 확인한다.

```bash
kubectl describe networkpolicy 3tier-default-deny
```

정책 대상 Pod와 허용 포트·Namespace·selector를 상세 확인한다.

정책 적용 후에도 외부 접근이 되는지 확인한다.

```bash
curl http://10.10.10.150:30198/
```

NetworkPolicy 적용 후 Ingress 경로를 통한 외부 Frontend 접근을 확인한다.

```bash
kubectl get pods -l app=frontend
```

정책 대상 Frontend Pod의 상태를 확인한다.

```bash
kubectl get pods -l app=fastcgi-backend
```

정책 대상 Backend Pod의 상태를 확인한다.

```bash
kubectl get pods -l app=mariadb
```

정책 대상 MariaDB Pod의 상태를 확인한다.

정책이 적용된 뒤 예상한 통신이 제한되면 다음 항목을 확인한다.

- `ingress-nginx` Namespace에 `kubernetes.io/metadata.name` 라벨이 있는지
- CoreDNS Pod에 `k8s-app: kube-dns` 라벨이 있는지
- Frontend·Backend·MariaDB Pod의 `app` 라벨이 정책과 일치하는지
- Calico Node와 Typha Pod가 정상인지

```bash
kubectl get namespace ingress-nginx kube-system --show-labels
```

Ingress Controller와 kube-system Namespace의 라벨을 확인한다.

```bash
kubectl -n kube-system get pods -l k8s-app=kube-dns
```

CoreDNS Pod의 selector 라벨과 실행 상태를 확인한다.

```bash
kubectl -n calico-system get pods
```

Calico 구성 Pod가 정상 실행 중인지 확인한다.

## 삭제

```bash
kubectl delete -f 3tier-networkpolicy.yml
```
