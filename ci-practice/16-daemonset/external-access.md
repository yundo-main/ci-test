# 16번 모니터링 서비스 외부 노출

16번 기본 실습의 Grafana와 Prometheus는 클러스터 내부 `ClusterIP` Service로
실행한다. 이 문서는 필요할 때만 외부 접근을 추가하는 선택형 확장 실습이다.

기본 실습은 외부에 노출하지 않는다.

```text
기본 구성
Grafana      ClusterIP:3000       클러스터 내부
Prometheus   ClusterIP:9090       클러스터 내부
Node Exporter Headless:9100       Prometheus 수집 전용
```

## 1. NodePort로 Grafana 외부 노출

NodePort는 모든 노드의 지정 포트로 Service를 노출한다. 테스트 환경에서만
사용하고, 방화벽과 접근 허용 범위를 함께 확인한다.

[`grafana-nodeport.yml`](./grafana-nodeport.yml)은 `grafana` Deployment의 Pod를
`30000` NodePort로 노출하는 별도 Service 예제다. 기본 `grafana` Service를
변경하지 않으므로 선택적으로 적용할 수 있다.

```bash
kubectl apply -f grafana-nodeport.yml
```

실제 파일로 저장한 NodePort 예제를 적용한다. 이 파일은 기본 `grafana.yml`과
분리해서 관리한다.

```bash
kubectl get service grafana-nodeport -n default -o wide
```

NodePort와 ClusterIP가 생성되었는지 확인한다.

```bash
curl http://노드IP:30000/api/health
```

노드 IP와 NodePort를 통해 Grafana Health API를 확인한다.

```bash
kubectl delete -f grafana-nodeport.yml
```

외부 노출용 NodePort만 삭제하고 기본 내부 Service는 유지한다.

## 2. Ingress로 Grafana 외부 노출

Ingress Controller가 설치되어 있다면 경로 또는 호스트 기반으로 Grafana를
노출할 수 있다. Ingress는 별도 리소스이며, `ingressClassName`과 Controller가
일치해야 한다.

[`grafana-ingress.yml`](./grafana-ingress.yml)은 `grafana` 내부 Service를 Ingress
뒤에 연결하는 선택형 예제다. DNS 또는 테스트
환경의 hosts 설정이 `grafana.example.test`를 Ingress NodePort 주소로 가리켜야 한다.

```bash
kubectl apply -f grafana-ingress.yml
```

Grafana Ingress 리소스를 생성한다.

```bash
kubectl get ingress grafana-external -n default
```

Ingress 주소와 생성 상태를 확인한다.

```bash
curl -H 'Host: grafana.example.test' http://노드IP:30198/api/health
```

HTTP Host 헤더를 사용해 NGINX Ingress Controller 경로를 확인한다. `30198`은
실제 Ingress Controller Service의 NodePort로 바꾼다.

```bash
kubectl delete -f grafana-ingress.yml
```

외부 노출 Ingress만 삭제한다.

## 3. 선택 기준

| 방식 | 접근 범위 | 용도 |
| --- | --- | --- |
| `ClusterIP` | 클러스터 내부 | 기본 모니터링 구성 |
| `NodePort` | 노드 IP와 포트 | 단순 테스트·임시 접근 |
| `Ingress` | Ingress Controller 경유 | 호스트·경로 기반 서비스 |

외부 노출이 끝나면 NodePort 또는 Ingress 리소스를 삭제하고, Grafana와
Prometheus는 기본 `ClusterIP` Service로 되돌린다.
