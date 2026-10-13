# Chapter 2. 서비스 고도화와 보안

Chapter 1에서 구성한 3-Tier 애플리케이션을 외부에 노출하고, 네트워크 제어·가용성·
보안·확장 리소스로 운영 수준을 높인다.

모든 실습은 [Chapter 1의 10-3tier](../10-3tier/README.md)에서 구성한
`frontend`, `fastcgi-backend`, `mariadb` Service와 Pod를 기준으로 확장한다.
새로운 애플리케이션을 만들지 않고 기존 3-Tier 서비스에 운영 기능을 추가한다.

## 학습 범위

| 단계 | 주제 |
| --- | --- |
| 11 | [Ingress 외부 노출](../11-ingress/README.md) |
| 12 | [NetworkPolicy](../12-networkpolicy/README.md) |
| 13 | [Probe·Scale](../13-probe-scale/README.md) |
| 14 | [Security](../14-security/README.md) |
| 15 | [Batch](../15-batch/README.md) |
| 16 | [DaemonSet·Node Exporter·Prometheus·Grafana](../16-daemonset/README.md) |
| 17 | [Cluster-scoped Resource](../17-cluster-scoped/README.md) |
| 18 | [Extension](../18-extension/README.md) |

## 학습 목표

- Ingress Controller와 경로 기반 외부 라우팅을 구성한다.
- 필요한 Pod 간 통신만 NetworkPolicy로 허용한다.
- Probe·Scale·RBAC로 서비스 운영 안정성과 보안을 강화한다.
- 클러스터 범위 리소스와 확장 리소스를 이해한다.

각 단계의 상세 설명과 파일은 위 표에서 확인한다.
