# ConfigMap

민감하지 않은 환경 변수나 설정 파일을 애플리케이션 코드와 분리해 관리한다.

MariaDB 초기화 SQL 예제:

- [`configmap.yml`](./configmap.yml)
- [`frontend.yml`](./frontend.yml): `frontend.yml`에서 추출한 HTML
- [`backend.yml`](./backend.yml): `backend.yml`에서 추출한 FastAPI 코드

## `examples`에서 실습 파일을 만드는 과정

`k8s/examples/1/db.yml`은 ConfigMap, PVC, Deployment, Service를 한 번에 적용하는
통합 예제다. 학습 단계에서는 그중 ConfigMap 부분만 분리해
`practice-order/06-configmap/configmap.yml`로 만든다.

### 1. 기준 예제에서 ConfigMap 찾기

[`k8s/examples/1/db.yml`](../../examples/1/db.yml)의 첫 번째 문서에서 다음 항목을
확인한다.

- `kind: ConfigMap`
- `metadata.name: mariadb-initdb-config`
- `data.init.sql`: MariaDB 최초 실행 SQL

PVC, Deployment, Service 문서는 다음 실습 단계의 범위이므로 함께 복사하지 않는다.

같은 방법으로 다음 ConfigMap도 분리한다.

- `k8s/examples/1/frontend.yml`의 `frontend-html` ConfigMap만
  [`frontend.yml`](./frontend.yml)에 복사한다.
- `k8s/examples/1/backend.yml`의 `backend-app` ConfigMap만
  [`backend.yml`](./backend.yml)에 복사한다.
- 각 원본 Deployment의 `volumes.configMap.name`과 실습 ConfigMap 이름이
  일치하는지 확인한다.

Frontend는 HTML 파일을 `/usr/share/nginx/html`에 마운트하고, Backend는
`main.py`를 `/app`에 마운트한다. 따라서 ConfigMap만 먼저 만들 수 있지만,
실제 파일을 사용하는 것은 이후 Deployment 실습에서 연결한다.

```bash
kubectl apply -f frontend.yml
```

Frontend HTML ConfigMap을 생성한다.

```bash
kubectl apply -f backend.yml
```

Backend 애플리케이션 코드 ConfigMap을 생성한다.

```bash
kubectl get configmap frontend-html backend-app
```

두 ConfigMap이 생성되었는지 확인한다.

Backend 예제의 DB 접속 정보는 학습용 코드에 포함된 값이다. 운영 환경에서는
비밀번호를 코드나 ConfigMap에 넣지 말고 Secret과 환경 변수로 분리한다.

### 2. 실습용 이름과 범위로 정리하기

예제의 `data.init.sql` 내용을 유지하고, StatefulSet에서 참조할 이름에 맞춰
ConfigMap 이름을 `mariadb-initdb`로 정리한다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mariadb-initdb
data:
  init.sql: |
    USE fcgidb;
    CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      username VARCHAR(64) NOT NULL UNIQUE,
      password VARCHAR(128) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
```

이 결과가 현재 디렉터리의 [`configmap.yml`](./configmap.yml)이다. 예제의
`CREATE DATABASE` 구문은 MariaDB 환경 변수의 `MARIADB_DATABASE=fcgidb`가
데이터베이스를 생성하므로 실습 파일에서는 제외했다.

### 3. 적용하고 결과 확인하기

```bash
kubectl apply -f configmap.yml
```

MariaDB 초기화 SQL ConfigMap을 생성한다.

```bash
kubectl get configmap mariadb-initdb
```

ConfigMap이 존재하는지 확인한다.

```bash
kubectl describe configmap mariadb-initdb
```

저장된 `init.sql` 키와 내용을 상세 확인한다.

다음 StatefulSet 단계에서는 이 ConfigMap을
`/docker-entrypoint-initdb.d/init.sql`로 마운트한다. ConfigMap은 일반 설정과
초기화 파일을 저장하며, 비밀번호 같은 민감정보는 [`../07-secret/`](../07-secret/README.md)의
Secret에서 관리한다.
