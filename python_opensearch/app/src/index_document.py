import json
import os
import sys
import time
from opensearchpy import OpenSearch


# .env 변수 설정
host = os.getenv('OS_HOST')
port = os.getenv('OS_PORT')
password = os.getenv('OPENSEARCH_INITIAL_ADMIN_PASSWORD')
# data_file_path = os.getenv('DATA_FILE_PATH')
# index_name = os.getenv('INDEX_NAME')
data_file_path = '/app/data/test_data_5000_embedded.json'
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


# 데이터 로드 함수
def load_data():
    try:
        with open(data_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        print(f"\n✅ 완료: 로우 데이터 파일 '{data_file_path}'의 로딩에 성공했습니다.")
        return data

    except FileNotFoundError:
        print(f"\n❌ 오류: 로우 데이터 파일 '{data_file_path}'을(를) 찾을 수 없습니다.")
        sys.exit(1)

    except json.JSONDecodeError:
        print(f"\n❌ 오류: 로우 데이터 파일 '{data_file_path}'의 JSON 형식이 올바르지 않습니다.")
        sys.exit(1)


# 데이터 인덱싱 함수
def index_data(products):
    BATCH_SIZE = 500

    bulk_data = []
    total_successes = 0
    total_errors = 0

    start = time.time()

    for i, product in enumerate(products):
        bulk_data.append(json.dumps({
            "index": {
                "_index": index_name,
                "_id": product["product_id"]
            }
        }))

        bulk_data.append(json.dumps(product, ensure_ascii=False))

        is_last_item = (i + 1) == len(products)
        if (i + 1) % BATCH_SIZE == 0 or is_last_item:
            bulk_body = '\n'.join(bulk_data) + '\n'

            response = client.bulk(body=bulk_body, request_timeout=60)
    
            if response['errors']:
                for item in response['items']:
                    if 'error' in item['index']:
                        total_errors += 1
                        print(f"❌ 오류: ID {item['index']['_id']} - {item['index']['error'].get('reason')}")
                    else:
                        total_successes += 1
            else:
                total_successes += len(response['items'])

            bulk_data = []
    
    end = time.time()

    # 실행 결과 출력
    total_docs = len(products)
    
    print(f'\n--- 인덱싱 최종 결과 ---')
    print(f'총 인덱싱 시도 문서: {total_docs}개')
    print(f"✅ 성공적으로 인덱싱된 문서: {int(total_successes)}개")
    print(f"❌ 인덱싱 실패한 문서: {total_errors}개")
    print(f"인덱싱 실행 시간: {end - start:.4f}초")


if __name__ == "__main__":
    raw_data = load_data()
    index_data(raw_data)
