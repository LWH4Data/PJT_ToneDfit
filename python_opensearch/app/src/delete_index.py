import os
import sys
import time
from opensearchpy import OpenSearch


# .env 변수 설정
host = os.getenv('OS_HOST')
port = os.getenv('OS_PORT')
# index_name = os.getenv('INDEX_NAME')
index_name = 'products_hybrid_v1'


# OpenSearch 클라이언트 설정
try:
    client = OpenSearch(
        hosts = [{'host': host, 'port': port}],
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


# 인덱스 삭제 함수
def delete_index():
    try:
        if not client.indices.exists(index=index_name):
            print(f"\n⚠️ 주의: 인덱스 '{index_name}'이(가) 존재하지 않습니다. 삭제할 인덱스가 없습니다.")
            return

        start = time.time()
        client.indices.delete(index=index_name)
        end = time.time()
        
        print(f"\n✅ 완료: 인덱스 '{index_name}'이(가) 성공적으로 삭제되었습니다.")
        print(f"\n인덱스 삭제 실행 시간: {end - start:.4f}초")

    except Exception as e:
        print(f"\n❌ 오류: 인덱스 삭제에 실패했습니다.\n{str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    delete_index()