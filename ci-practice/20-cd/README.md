# 20. CD 배포

CD(Continuous Delivery/Deployment, 지속적 제공·배포)는 CI를 통과한 변경을
컨테이너 이미지로 만들고 대상 환경에 배포하는 과정이다.

- [실습용 CD workflow](./cd.yml)
- [CD 실습 흐름 SVG](./cd-overview.svg)

![CD 실습 흐름](./cd-overview.svg)

## CD란?

CI가 코드와 Manifest를 검사하는 단계라면, CD는 검증된 결과를 실제 실행 환경에
전달하는 단계다. 이 실습의 CD는 Docker Hub에 이미지를 Push한 뒤 kubeconfig로
Kubernetes 클러스터에 접속하여 Deployment를 갱신한다.

```text
CI 성공
   ↓
Git Tag 또는 수동 실행
   ↓
Docker 이미지 Build
   ↓
Docker Hub Push
   ↓
Kubernetes 배포
   ↓
Rollout 상태 확인
```

| 구분 | 역할 |
| --- | --- |
| CI | 코드와 Kubernetes Manifest를 검사한다. |
| CD | 이미지를 만들고 저장소에 Push한 뒤 클러스터에 배포한다. |

## 저장소 설정

19번에서 만든 `/Users/jarrod/project/code-test/ci-test` 작업 디렉터리와
`ci-test` 저장소를 계속 사용한다. 기존 Kubernetes 저장소와 분리된 저장소의
`.github/workflows`에 CD workflow를 등록한다.

### 1. CD 파일 복사

19번에서 복사한 `ci-practice` 디렉터리 안의 CD workflow를 사용한다.

```bash
mkdir -p .github/workflows
```

GitHub Actions workflow 디렉터리를 만든다.

```bash
cp ci-practice/20-cd/cd.yml .github/workflows/cd.yml
```

CD workflow를 GitHub Actions 실행 위치로 복사한다.

필요한 GitHub Secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
KUBE_CONFIG
```

`DOCKERHUB_USERNAME`은 Docker Hub 사용자 이름이다.

`DOCKERHUB_TOKEN`은 Docker Hub Access Token이다. 일반 비밀번호 대신 토큰을
사용한다.

`KUBE_CONFIG`는 배포 대상 클러스터에 접근할 수 있는 kubeconfig를 Base64로
인코딩한 값이다. kubeconfig 원문을 저장소 파일이나 코드에 직접 넣지 않는다.

현재 workflow는 다음 조건에서 실행된다.

```yaml
on:
  workflow_dispatch:
  push:
    tags: ["v*"]
```

GitHub Actions에서 수동으로 실행하거나 `v1.0.0`처럼 `v`로 시작하는 Tag를
Push하면 실행된다.

## 배포 확인

```bash
kubectl rollout status deployment/frontend
```

Frontend Deployment의 새 버전 배포가 완료될 때까지 기다린다.

```bash
kubectl rollout status deployment/fastcgi-backend
```

Backend Deployment의 새 버전 배포가 완료될 때까지 기다린다.

```bash
kubectl get pods
```

CD 배포 후 전체 Pod 상태를 확인한다.

CD는 실제 클러스터와 Docker Hub에 변경을 반영하므로 19번 CI가 성공한 뒤 실행한다.
배포 실패 시 24번 Rollout과 이후 Rollback 실습에서 상태를 확인한다.
