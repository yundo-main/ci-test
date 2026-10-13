# 애플리케이션 Secret

이미지 Pull 인증용 Secret과 애플리케이션 실행에 필요한 Secret을 구분한다.

이 단계의 `secret.yml`은 MariaDB 초기화에 사용하는 데이터베이스와 비밀번호를
정의한다.

- [`secret.yml`](./secret.yml)

실습용 값이므로 운영 환경에서는 외부 Secret 관리 도구를 사용하고 저장소에
커밋하지 않는다.
