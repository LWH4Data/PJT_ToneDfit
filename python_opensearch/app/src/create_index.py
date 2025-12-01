import json
import os
import sys
import time
from opensearchpy import OpenSearch


# .env 변수 설정
host = os.getenv('OS_HOST')
port = os.getenv('OS_PORT')
password = os.getenv('OPENSEARCH_INITIAL_ADMIN_PASSWORD')
# mapping_file_path = os.getenv('MAPPING_FILE_PATH')
# index_name = os.getenv('INDEX_NAME')
mapping_file_path = '/app/mappings/products_hybrid_v1_mapping.json'
index_name = 'products_hybrid_v1'


# OpenSearch 클라이언트 설정
try:
    client = OpenSearch(
        hosts = [{'host': host, 'port': port}],
        http_auth=('admin', password),
        http_compress = True, # gzip 압축 활성화
        use_ssl = False,
        verify_certs = False,
        ssl_assert_hostname = False,
        ssl_show_warn = False
    )

    print(f"\n✅ 완료: OpenSearch 클라이언트 초기화에 성공했습니다.")

except Exception as e:
    print(f"\n❌ 오류: OpenSearch 클라이언트 초기화에 실패했습니다.\n{str(e)}")
    sys.exit(1)


# 매핑 파일 로드 함수
def load_mapping():
    try:
        with open(mapping_file_path, 'r', encoding='utf-8') as f:
            index_body = json.load(f)

        print(f"\n✅ 완료: 매핑 파일 '{mapping_file_path}'의 로딩에 성공했습니다.")
        return index_body

    except FileNotFoundError:
        print(f"\n❌ 오류: 매핑 파일 '{mapping_file_path}'을(를) 찾을 수 없습니다.")
        sys.exit(1)

    except json.JSONDecodeError:
        print(f"\n❌ 오류: 매핑 파일 '{mapping_file_path}'의 JSON 형식이 올바르지 않습니다.")
        sys.exit(1)


# 인덱스 생성 함수
def create_index(index_body):
    try:
        if client.indices.exists(index=index_name):
            print(f"\n⚠️ 주의: 인덱스 '{index_name}'이(가) 이미 존재합니다. 인덱스 생성을 중지합니다.")
            return

        start = time.time()
        client.indices.create(index=index_name, body=index_body)
        end = time.time()
        print(f"\n✅ 완료: 인덱스 '{index_name}'이(가) 성공적으로 생성되었습니다.")
        print(f"\n인덱스 생성 실행 시간: {end - start:.4f}초")

        # 생성된 인덱스 정보 조회
        index_info = client.indices.get(index=index_name)

        print("\n📌 생성된 인덱스 정보 요약")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(f"• 인덱스명: {index_name}")
        print(f"• 샤드 수: {index_info[index_name]['settings']['index']['number_of_shards']}")
        print(f"• 레플리카 수: {index_info[index_name]['settings']['index']['number_of_replicas']}")
        print("• 매핑 필드 목록:")

        mappings = index_info[index_name]['mappings']['properties']
        for field, field_info in mappings.items():
            field_type = field_info.get('type', 'object')
            print(f"   - {field}: {field_type}")

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    except Exception as e:
        print(f"\n❌오류: 인덱스 생성에 실패했습니다.\n{str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    index_body = load_mapping()
    create_index(index_body)
