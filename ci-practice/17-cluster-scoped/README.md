# 클러스터 범위 및 Namespace 운영 리소스

Namespace, Node, 자원 제한, Lease처럼 애플리케이션 Namespace보다 넓은 범위를
관리하는 리소스를 확인한다. 모든 리소스가 Cluster-scoped인 것은 아니므로 범위를
먼저 구분한다.

| 리소스 | 범위 | 확인 명령 |
| --- | --- | --- |
| Namespace | Cluster-scoped | `kubectl get namespaces` |
| Node | Cluster-scoped | `kubectl get nodes` |
| ResourceQuota | Namespace-scoped | `kubectl get resourcequota -n <namespace>` |
| LimitRange | Namespace-scoped | `kubectl get limitrange -n <namespace>` |
| Lease | Namespace-scoped | `kubectl get lease -A` |

세부 개념:

- [Namespace](./namespace/README.md)
- [Node](./node/README.md)
- [ResourceQuota](./resourcequota/README.md)
- [LimitRange](./limitrange/README.md)
- [Lease](./lease/README.md)

## 1. Cluster-scoped 리소스 확인

```bash
kubectl get namespaces
```

클러스터에 존재하는 Namespace와 상태를 확인한다.

```bash
kubectl get nodes -o wide
```

Node의 Ready 상태, IP, 운영체제와 CPU 아키텍처를 확인한다.

```bash
kubectl describe node <node-name>
```

특정 Node의 Taint, 자원, 조건, 이벤트를 상세 확인한다.

## 2. Namespace-scoped 리소스 확인

```bash
kubectl get resourcequota,limitrange -n default
```

`default` Namespace에 적용된 ResourceQuota와 LimitRange를 함께 확인한다.

```bash
kubectl get lease -A
```

모든 Namespace의 Lease를 확인한다. Lease는 Controller와 노드 heartbeat 또는
리더 선출에 사용될 수 있으므로 임의로 삭제하지 않는다.

## 3. 기존 3-Tier 자원 제한 예제

[`3tier-limits.yml`](./3tier-limits.yml)은 현재 Namespace에 3-Tier 실습용
CPU·메모리·Pod 수 제한과 컨테이너 기본 자원값을 설정한다.

```bash
kubectl apply -f 3tier-limits.yml
```

현재 Namespace에 ResourceQuota와 LimitRange를 적용한다. 이 파일은 Namespace를
생성하지 않으므로 대상 Namespace가 먼저 존재해야 한다.

```bash
kubectl get resourcequota 3tier-quota
```

Namespace의 CPU·메모리·Pod 사용량과 제한량을 요약해 확인한다.

```bash
kubectl get limitrange 3tier-default-limits
```

컨테이너 기본 requests/limits를 설정하는 LimitRange를 확인한다.

```bash
kubectl describe resourcequota 3tier-quota
```

Quota의 상세 제한값과 현재 사용량을 확인한다.

```bash
kubectl describe limitrange 3tier-default-limits
```

LimitRange의 기본 requests/limits와 최대 자원 정책을 상세 확인한다.

## 4. LimitRange 초과 실습

[`limits-failure.yml`](./limits-failure.yml)은 의도적으로 `LimitRange`의 최대값을
초과하는 Pod다. 먼저 제한을 적용한 뒤 실패를 확인한다.

```bash
kubectl apply -f 3tier-limits.yml
```

`default` Namespace에 최대 CPU 1개와 메모리 1Gi 제한을 적용한다.

```bash
kubectl apply -f limits-failure.yml
```

LimitRange의 최대값을 초과하므로 `must be less than or equal to max`와 같은
Admission 오류가 발생해야 한다. 이 명령은 정상적으로 실패하는 것이 실습 결과다.

```bash
kubectl get pod limits-failure-check -n default
```

Admission 단계에서 거부되므로 Pod가 생성되지 않아야 한다.

```bash
kubectl delete -f limits-failure.yml --ignore-not-found
```

실패 검증용 Pod가 생성된 경우에 대비해 삭제한다.

## 5. LimitRange 기본값 검증

다음 테스트 Pod는 컨테이너에 자원 requests/limits를 직접 작성하지 않는다.
LimitRange가 적용되어 있으면 Kubernetes가 기본값을 주입한다.

```bash
kubectl run limitrange-check \
  --image=nginx:stable \
  --restart=Never \
  -n default
```

기본 자원값 주입을 확인할 테스트 Pod를 생성한다.

```bash
kubectl get pod limitrange-check -n default -o yaml
```

Pod YAML의 `spec.containers[].resources`에 `requests`와 `limits`가 자동으로
추가되었는지 확인한다.

```bash
kubectl delete pod limitrange-check -n default
```

검증용 Pod를 삭제한다.

## 6. ResourceQuota 사용량 검증

```bash
kubectl get resourcequota 3tier-quota -n default -o yaml
```

`status.hard`의 제한량과 `status.used`의 현재 사용량을 비교한다.

```bash
kubectl describe resourcequota 3tier-quota -n default
```

Quota에 포함된 Pod·CPU·메모리 사용량과 제한 초과 여부를 이벤트와 함께 확인한다.

## 7. 정리

```bash
kubectl delete -f 3tier-limits.yml
```

현재 Namespace의 `3tier-quota`와 `3tier-default-limits`만 삭제한다. 이미 실행 중인
Pod를 직접 삭제하는 명령은 아니지만, 이후 생성되는 Pod의 자원 기본값과 제한이
달라질 수 있으므로 운영 환경에서는 영향 범위를 확인한다.
