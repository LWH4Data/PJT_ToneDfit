"""OpenSearch 클라이언트 설정"""
from functools import lru_cache
from opensearchpy import OpenSearch
from app.core.config import settings

@lru_cache(maxsize=1)
def get_opensearch_client() -> OpenSearch:
    return OpenSearch(
        hosts=[{
            'host': settings.opensearch_host,
            'port': settings.opensearch_port
        }],
        http_compress=True,
        use_ssl=False,
        verify_certs=False,
        ssl_assert_hostname=False,
        ssl_show_warn=False,
    )