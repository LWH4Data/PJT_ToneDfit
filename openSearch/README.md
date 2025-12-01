opensearch/
├─ compose.yaml
├─ .env
├─ config/
│  ├─ opensearch.yml          # path.repo 등 최소 설정
│  └─ log4j2.properties       # 로그: 1일 주기 + 파일당 20MB 로테이션
├─ analysis/
│  ├─ nori_custom_dict.txt
│  └─ synonyms.txt
├─ mappings/                  # 인덱스 매핑/템플릿/파이프라인 JSON
│  ├─ item-index.json
│  ├─ item-template.json
│  └─ ingest-pipeline.json
├─ python/                    # 개발 코드(스크립트/노트북 등)
│  ├─ apply_mappings.py
│  └─ notebooks/
├─ logs/                      # OpenSearch 런타임 로그 (바인드)
└─ snapshots/                 # 스냅샷 저장소 (path.repo=/mnt/snapshots)