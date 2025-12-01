fashion-embedding-project/
├─ data/
│  ├─ raw/
│  │  └─ products.json                   # ⬅️ 입력(원본) 제품 메타데이터
│  ├─ processed/
│  │  ├─ fashion_products.docs.json      # ⬅️ 임베딩 문서(검수용)
│  │  ├─ fashion_products.bulk.ndjson    # ⬅️ OS 벌크 적재 파일
│  │  └─ fashion_products.mapping.json   # ⬅️ OS 인덱스 매핑
│  └─ logs/
│     └─ prepare_vectors.log             # (옵션) 실행 로그
│
├─ scripts/
│  └─ prepare_vectors_offline.py         # ⬅️ 오프라인 임베딩 + 파일 생성
│
├─ env/
│  └─ requirements.txt                   # 의존성
│
└─ README.md
