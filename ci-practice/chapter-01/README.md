# Chapter 1. Kubernetes 기본 구성과 3-Tier 구축

설치가 완료된 클러스터에서 Kubernetes 기본 리소스를 익히고, NFS 스토리지를
사용하는 3-Tier 애플리케이션을 내부 Service로 구성한다.

## 학습 범위

| 단계 | 주제 |
| --- | --- |
| 01 | [이미지 Pull Secret](../01-image-pull-secret/README.md) |
| 02 | [Pod](../02-pod/README.md) |
| 03 | [ReplicaSet](../03-replicaset/README.md) |
| 04 | [Deployment](../04-deployment/README.md) |
| 05 | [Service](../05-service/README.md) |
| 06 | [ConfigMap](../06-configmap/README.md) |
| 07 | [애플리케이션 Secret](../07-secret/README.md) |
| 08 | [Persistent Storage](../08-storage/README.md) |
| 09 | [StatefulSet](../09-statefulset/README.md) |
| 10 | [3-Tier 내부 구성](../10-3tier/README.md) |

## 학습 목표

- 기본 Workload와 Service의 관계를 이해한다.
- 설정·인증정보·스토리지를 애플리케이션과 분리한다.
- Frontend·Backend·MariaDB를 ClusterIP Service로 연결한다.
- 외부 노출 전 내부 DNS와 Service 통신을 검증한다.

설치 후 클러스터 확인은 상위 [실습 순서](../README.md)에서 진행하고,
각 단계의 상세 설명과 파일은 위 표에서 확인한다.
