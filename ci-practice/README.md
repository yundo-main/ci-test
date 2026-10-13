# Kubernetes 실습 순서

이 디렉터리는 Lesson 0 설치부터 Kubernetes 클러스터 실습 파일을 순서대로
실행하는 학습 경로다.

[Lesson 0. Kubernetes 설치](../install/plan.md)에서 클러스터를 먼저 준비한다.
`examples/`는 실습 파일 생성을 위한 내부 기반 예제이므로 학습 경로에 포함하지
않는다.

## 챕터 구성

- [Chapter 1. Kubernetes 기본 구성과 3-Tier 구축](./chapter-01/README.md)
- [Chapter 2. 서비스 고도화와 보안](./chapter-02/README.md)
- [Chapter 3. DevOps와 CI/CD](./chapter-03/README.md)

## 전체 순서

```text
00 Lesson 0. Kubernetes 설치
  ↓
01 이미지 Pull Secret
  ↓
02 Pod
  ↓
03 ReplicaSet
  ↓
04 Deployment
  ↓
05 Service
  ↓
06 ConfigMap
  ↓
07 애플리케이션 Secret
  ↓
08 Persistent Storage
  ↓
09 StatefulSet
  ↓
10 3-Tier Application
  ↓
11 Ingress
  ↓
12 NetworkPolicy
  ↓
13 Probe·Scale (Metrics Server 선행)
  ↓
14 Security
  ↓
15 Batch Workload
  ↓
16 DaemonSet·Node Exporter·Prometheus·Grafana
  ↓
17 Cluster-scoped Resource
  ↓
18 Extension
  ↓
19 CI 검증 (ci-test 저장소)
  ↓
20 CD 배포 (ci-test 저장소)
  ↓
21~26 DevOps 확장 (ci-test 저장소)
  ↓
27~32 DevSecOps
  ↓
Addons·Operations
```

## Chapter 1. Kubernetes 기본 구성과 3-Tier 구축

01~10단계는 기본 리소스 학습과 3-Tier 내부 구성까지 진행한다.

## 1. 설치 후 클러스터 확인

설치가 끝난 뒤 노드와 시스템 Pod가 정상인지 확인한다.

```bash
kubectl get nodes -o wide
```

모든 노드의 Ready 상태와 주소를 확인한다.

```bash
kubectl get pods -A
```

시스템 Pod와 Addon Pod의 상태를 확인한다.

```bash
kubectl get events -A --sort-by=.lastTimestamp
```

최근 클러스터 이벤트를 시간순으로 확인한다.

모든 노드가 `Ready`이고 CNI 관련 Pod가 정상이어야 다음 단계로 진행한다.

노드 CPU 아키텍처와 실습 이미지가 일치하는지도 확인한다. 특히 ARM64
클러스터에서 AMD64 전용 이미지를 사용하면 이미지 Pull 이후에도
`exec format error`가 발생할 수 있다.

```bash
bash ../operations/01-cluster/check-architecture.sh
```

이 점검 결과는 기록용이며 클러스터 리소스를 변경하지 않는다. 현재 점검
클러스터는 모든 노드가 ARM64이고, 08-storage의 기존
`itsthenetwork/nfs-server-alpine:latest` 이미지는 ARM64에서 실행되지 않았다.
현재 08-storage는 `andrewkidd/nfs-server:v2.2.7`과 노드 NFS 커널 모듈 준비
DaemonSet을 사용한다.

## 실습별 선행조건 확인

각 실습은 해당 디렉터리의 README에 있는 파일 순서와 선행조건을 먼저 확인한
뒤 적용한다. 전체 실습을 무조건 연속 적용하지 않는다.

| 단계 | 먼저 준비할 파일·구성요소 | 시작 전 확인 |
| --- | --- | --- |
| 01~07 | 이미지 Pull Secret, ConfigMap, 애플리케이션 Secret | 노드 상태와 이미지 아키텍처 |
| 08 | `nfs-pod.yml`, `nfs-service.yml`, `nfs-storageclass.yml`, `nfs-pvc.yml` | NFS CSI Driver, ARM64 호환 NFS 이미지 |
| 09 | 08번의 `nfs-csi` StorageClass, 05~07번 리소스 | PVC가 `Bound`인지 확인 |
| 10 | 06번 ConfigMap, 07번 Secret | MariaDB·Backend·Frontend 순서 |
| 11 | 10번의 Frontend·Backend Service | `kubectl get ingressclass nginx` |
| 12 | Calico CNI, 10·11번 정상 동작 | DNS와 Ingress Controller 라벨 |
| 13 | 10번 Backend, PriorityClass, PDB | `kubectl top pods` |
| 14~18 | 10번 3-Tier 및 관련 기반 리소스 | 각 README의 적용 순서 |

기본 클러스터 설치는 [Lesson 0 Playbook](../install/playbooks/README.md)에서
진행하고, 선택형 Addon 설치는 [Addon 설치 순서](../install/addons/README.md)에서
별도로 진행한다.

Chapter 1은 01~10단계, Chapter 2는 11~18단계로 구성한다.

## 19번부터 별도 저장소 사용

01~18번은 기존 Kubernetes 학습 저장소에서 진행하고, 19번부터 32번까지의
CI·CD·DevOps·DevSecOps 실습은 `/Users/jarrod/project/code-test/ci-test`라는
별도 작업 디렉터리와 GitHub 저장소를 사용한다. 기존 `practice-order` 전체를
`ci-practice`라는 이름으로 복사하며, 기존 저장소는 수정하거나 삭제하지 않는다.

19번 CI부터는 [ci-test 저장소 실습 절차](./19-ci/README.md#ci-test-저장소로-실습하기)를 먼저 수행한다. 이후 필요한 workflow와 검사 파일은
`ci-test` 저장소 안에서 직접 구성한다.

## 01. Docker Hub 이미지 Pull Secret

[01-image-pull-secret](./01-image-pull-secret/README.md)의 명령으로 Private
이미지 Pull Secret을 생성한다.

```bash
read -s DOCKER_PAT
echo
```

`read`로 Docker Hub PAT를 입력받고, `echo`로 입력 줄을 종료한다. PAT는 화면에
표시되지 않는다.

```bash
kubectl create secret docker-registry jarrod-secret-test \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=jarrodkim \
  --docker-password="$DOCKER_PAT" \
  --docker-email='YOUR_EMAIL'
```

현재 Namespace에 이미지 Pull Secret을 생성한다.

```bash
unset DOCKER_PAT
```

터미널에서 PAT 환경변수를 제거한다.

```bash
kubectl get secret jarrod-secret-test
```

이미지 Pull Secret이 생성되었는지 확인한다.

이 Secret은 이미지 Pull 인증용이다. MariaDB 비밀번호용 Secret은 07단계에서
별도로 사용한다. Secret은 Namespace별로 생성해야 한다.

## 실습 이미지 정책

Storage·ConfigMap 이전 단계는 설정이 이미지에 포함된 테스트 이미지를 사용한다.

| 역할 | 이미지 |
| --- | --- |
| Frontend·Nginx | `jarrodkim/nginx-test:latest` |
| Backend·FastAPI | `jarrodkim/fastapi-test:latest` |
| Database·MariaDB | `jarrodkim/mariadb-test:latest` |

09 StatefulSet 단계부터는 `mariadb:11`과 ConfigMap·Secret·PVC를 조합해
이미지와 실행 설정을 분리한다.

## 02. Pod

[02-pod](./02-pod/README.md)에서 단일 Pod와 컨테이너 간 통신을 실습한다.

```bash
kubectl apply -f k8s/practice-order/02-pod/1container.yml
```

단일 컨테이너 Pod를 생성한다.

```bash
kubectl get pod -o wide
```

Pod 상태와 배치된 노드를 확인한다.

```bash
kubectl delete -f k8s/practice-order/02-pod/1container.yml
```

단일 컨테이너 Pod를 삭제한다.

2컨테이너와 3컨테이너 예제는 [02-pod](./02-pod/)에서 확인한다.

## 03. ReplicaSet

[03-replicaset](./03-replicaset/README.md)에서 지정한 Pod 복제본 수를 유지한다.

```bash
kubectl apply -f k8s/practice-order/03-replicaset/nginx.yml
```

ReplicaSet을 생성한다.

```bash
kubectl get rs,pods -l app=nginx-replicaset
```

ReplicaSet과 관리 대상 Pod를 확인한다.

```bash
kubectl scale rs nginx-replicaset --replicas=5
```

ReplicaSet의 Pod 수를 5개로 변경한다.

```bash
kubectl delete -f k8s/practice-order/03-replicaset/nginx.yml
```

ReplicaSet과 Pod를 삭제한다.

## 04. Deployment

[04-deployment](./04-deployment/README.md)에서 ReplicaSet 관리, 롤링 업데이트,
롤백과 스케일링을 실습한다.

```bash
kubectl apply -f k8s/practice-order/04-deployment/nginx.yml
```

Deployment를 생성한다.

```bash
kubectl rollout status deployment/nginx-deployment
```

Deployment의 현재 배포가 완료될 때까지 기다린다.

```bash
kubectl get deployment,rs,pods -l app=nginx-deployment
```

Deployment와 ReplicaSet, Pod 상태를 확인한다.

```bash
kubectl rollout history deployment/nginx-deployment
```

Deployment revision 이력을 확인한다.

```bash
kubectl delete -f k8s/practice-order/04-deployment/nginx.yml
```

Deployment가 생성한 리소스를 삭제한다.

## 05. Service

[05-service](./05-service/README.md)에서 변경되는 Pod IP를 고정된 Service
엔드포인트로 연결한다.

## 06. ConfigMap

[06-configmap](./06-configmap/README.md)에서 일반 설정과 초기화 SQL을 이미지와
분리한다. MariaDB 초기화 파일은 [configmap.yml](./06-configmap/configmap.yml)에
있다.

## 07. 애플리케이션 Secret

[07-secret](./07-secret/README.md)에서 애플리케이션 인증정보를 별도 Secret으로
관리한다. 이미지 Pull Secret과 용도를 구분한다.

## 08. Persistent Storage

[08-storage](./08-storage/README.md)에서 NFS Server Pod, NFS CSI Driver,
StorageClass, PVC의 관계를 확인한다.

## 09. StatefulSet

[09-statefulset](./09-statefulset/README.md)에서 고정 Pod 이름, Headless Service,
ConfigMap, Secret, PVC를 MariaDB에 조합한다.

```bash
kubectl apply -f k8s/practice-order/08-storage/nfs-pod.yml
```

NFS 서버 Pod를 생성한다.

```bash
kubectl apply -f k8s/practice-order/08-storage/nfs-service.yml
```

NFS 서버 Service를 생성한다.

```bash
kubectl apply -f k8s/practice-order/08-storage/nfs-storageclass.yml
```

NFS용 StorageClass를 생성한다.

```bash
kubectl apply -f k8s/practice-order/08-storage/nfs-pvc.yml
```

동적 볼륨을 요청하는 PVC를 생성한다.

```bash
kubectl apply -f k8s/practice-order/07-secret/secret.yml
```

MariaDB 인증정보 Secret을 생성한다.

```bash
kubectl apply -f k8s/practice-order/06-configmap/configmap.yml
```

MariaDB 초기화 SQL ConfigMap을 생성한다.

```bash
kubectl apply -f k8s/practice-order/05-service/service.yml
```

MariaDB용 Service를 생성한다.

```bash
kubectl apply -f k8s/practice-order/09-statefulset/statefulset.yml
```

MariaDB StatefulSet을 생성한다.

```bash
kubectl rollout status statefulset/mariadb
```

StatefulSet의 Pod가 준비될 때까지 기다린다.

```bash
kubectl get statefulset,pod,pvc,service
```

StatefulSet, Pod, PVC, Service 상태를 확인한다.

실습 종료 시 StatefulSet과 연결 리소스를 삭제한다. PVC는 데이터 보존을 위해
별도로 삭제한다.

```bash
kubectl delete -f k8s/practice-order/09-statefulset/statefulset.yml
```

MariaDB StatefulSet을 삭제한다.

```bash
kubectl delete -f k8s/practice-order/05-service/service.yml
```

MariaDB Service를 삭제한다.

```bash
kubectl delete -f k8s/practice-order/06-configmap/configmap.yml
```

MariaDB 초기화 SQL ConfigMap을 삭제한다.

```bash
kubectl delete -f k8s/practice-order/07-secret/secret.yml
```

MariaDB 인증정보 Secret을 삭제한다.

```bash
kubectl delete pvc mariadb-data-mariadb-0
```

남은 MariaDB PVC를 삭제한다. 이 명령은 저장된 실습 데이터를 제거한다.

## 10. 3-Tier Application

[10-3tier](./10-3tier/)에서 09단계의 MariaDB StatefulSet과 초기
Frontend·Backend 이미지를 연결하고 내부 ClusterIP Service 통신을 확인한다.

## Chapter 2. 서비스 고도화와 보안

11~18단계는 외부 노출, 네트워크 제어, 가용성, 보안과 확장 리소스를 다룬다.

## 11. Ingress

[11-ingress](./11-ingress/)에서 Ingress Controller 상태와 `nginx` IngressClass를
확인하고, `/`와 `/api/` 경로 라우팅을 통해 3-Tier를 외부에 노출한다.

## 12. NetworkPolicy

[12-networkpolicy](./12-networkpolicy/)에서 Pod 간 ingress·egress 네트워크 정책과
EndpointSlice를 학습한다.

## 13. Probe·Scale

[13-probe-scale](./13-probe-scale/)에서 readiness/liveness, PDB, PriorityClass,
HPA를 학습한다.

## 14. Security

[14-security](./14-security/)에서 ServiceAccount, Role, RoleBinding,
ClusterRole을 학습한다.

## 15. Batch Workload

[15-batch](./15-batch/)에서 Job과 CronJob을 학습한다.

## 16. DaemonSet

[16-daemonset](./16-daemonset/)에서 Node Exporter를 DaemonSet으로 배포해 노드별
메트릭을 제공하고, Prometheus로 수집한 메트릭을 Grafana에서 시각화한다.

## 17. Cluster-scoped Resource

[17-cluster-scoped](./17-cluster-scoped/)에서 Node, Namespace, ResourceQuota,
LimitRange 등을 학습한다.

## 18. Extension

[18-extension](./18-extension/)에서 CRD와 Custom Resource를 학습한다.

## Addons·Operations

기본 리소스 학습 이후 다음 영역으로 확장한다.

- [Operations 이론](../operations/operations-theory.md)
- [Addon 설치 순서](../install/addons/README.md)
- [운영 Addon 자료](../operations/07-addons/README.md): CNI, Ingress, Storage, Operator
- [Operations](../operations/README.md): 클러스터·노드·네트워크·장애 대응

## Chapter 3. DevOps와 CI/CD

Kubernetes 실습 결과를 대상으로 CI 검증, Docker 이미지 빌드·Push, 배포와
Rollout 확인을 자동화한다.

- [DevOps·CI/CD 실습](./chapter-03/README.md)

## 주의사항

- `k8s/install/`은 Lesson 0 설치 자동화, `k8s/examples/`는 실습 파일 생성을
  위한 내부 기반 예제다.
- 테스트용 `latest` 태그는 이미지 변경으로 결과가 달라질 수 있다.
- Secret 값과 kubeconfig는 저장소에 커밋하지 않는다.
- 기존 `k8s/examples/1/db.yml`과 StatefulSet MariaDB 예제를 동시에 적용하지 않는다.
