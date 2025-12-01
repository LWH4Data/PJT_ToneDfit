# --------------------------------------------------------------------------
# 1단계: 빌드 스테이지 (builder)
# 컴파일이 필요한 라이브러리가 없으므로, 처음부터 가벼운 'slim' 이미지를 사용합니다.
FROM python:3.12-slim AS builder 

# 의존성을 설치할 작업 디렉터리 설정
WORKDIR /app

# requirements.txt 복사
# 캐시 무효화를 최소화하기 위해 코드 복사 전에 실행
COPY requirements.txt .

# pip wheel 명령을 사용하여 의존성 패키지(FastAPI, Uvicorn)를 미리 빌드합니다.
# 시스템 빌드 도구(build-essential) 설치 과정이 필요 없으므로 제거됩니다.
RUN pip wheel --no-cache-dir --wheel-dir /usr/src/app/wheels -r requirements.txt

# --------------------------------------------------------------------------

# 2단계: 최종 스테이지 (final)
# 실제 애플리케이션 실행을 위한 가장 가볍고 깔끔한 'slim' 이미지를 사용합니다.
FROM python:3.12-slim

# 작업 디렉터리 설정
WORKDIR /app

# 1단계에서 빌드된 wheel 파일들을 복사
COPY --from=builder /usr/src/app/wheels /wheels

# 복사된 wheel 파일들을 설치합니다.
# NumPy/Pandas 지원을 위한 libgfortran5 설치 과정이 제거됩니다.
RUN pip install --no-cache /wheels/*

# 애플리케이션 소스 코드 복사
COPY . .

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1

# 포트 지정
EXPOSE 8000

# 애플리케이션 실행 명령어 (Uvicorn)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

### Numpy, Pandas 와 같은 복잡한 모듈을 사용하게 된다면, 빌드가 수정되어야합니다.
### 현재는 그런 라이브러리들을 배제한 경량화 이미지를 빌드합니다.