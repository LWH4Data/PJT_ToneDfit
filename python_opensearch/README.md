# 디렉터리 구조
opensearch/
├─ app/
│  ├─ src/
│  │  ├─ main.py          # 엔트리포인트
│  │  ├─ client.py        # OpenSearch 연결 헬퍼
│  │  └─ indexer.py       # (선택) 인덱스 생성/로딩 등
│  ├─ requirements.txt
│  ├─ .env
│  └─ dev.sh
├─ Dockerfile
└─ compose.yaml
