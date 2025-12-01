FROM postgres:16.3

ENV TZ=Asia/Seoul

# 컨테이너 내 기본 설정 경로 준비
RUN mkdir -p /etc/postgresql && chown -R postgres:postgres /etc/postgresql

# 설정 파일을 이미지에 내장
COPY --chown=postgres:postgres config/postgresql.conf /etc/postgresql/postgresql.conf
COPY --chown=postgres:postgres config/pg_hba.conf       /etc/postgresql/pg_hba.conf

# 초기화 스크립트 추가(빈 데이터 디렉터리일 때 1회 실행)
COPY --chown=postgres:postgres init/ /docker-entrypoint-initdb.d/

# 엔트리포인트와 기본 CMD는 베이스 이미지 그대로 사용
# compose에서 -c config_file=... 로 커스텀 설정을 명시
