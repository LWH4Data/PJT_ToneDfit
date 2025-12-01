FROM python:3.12-slim

# 러닝타임 의존성 (confluent-kafka용)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates tini librdkafka1 chromium chromium-driver && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 의존성 고정
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 앱 소스 복사
COPY . /app

# (선택) 비루트 유저
RUN useradd -m appuser
USER appuser

ENTRYPOINT ["/usr/bin/tini", "--"]
