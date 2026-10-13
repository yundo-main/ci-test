# PriorityClass

Pod 스케줄링 우선순위를 정의하고 자원 부족 시 선점 순서를 결정한다.

## Backend 예제

[`fastcgi-backend-priority.yml`](./fastcgi-backend-priority.yml)은 Backend Pod에
우선순위 `1000000`을 부여한다. Deployment의 `priorityClassName`이 이 이름을
참조한다.

```bash
kubectl apply -f fastcgi-backend-priority.yml
```

Backend Pod가 사용할 PriorityClass를 생성한다.

```bash
kubectl get priorityclass fastcgi-backend-high
```

PriorityClass의 우선순위 값과 전역 기본값 여부를 확인한다.
