from opensearchpy import OpenSearch, OpenSearchException
from app.libraries.opensearch_client import get_opensearch_client
from app.core.config import settings
from typing import Dict, Any

class ProductsRepository:
    def __init__(self):
        self.client: OpenSearch = get_opensearch_client()
        self.index_name = settings.products_index_name
    
    async def search(self, query_body: Dict[str, Any]) -> Dict[str, Any]:
        """OpenSearch 검색 실행"""
        try:
            print(f"Executing OpenSearch query: {query_body}")
            response = self.client.search(
                index=self.index_name,
                body=query_body
            )
            return response
        except OpenSearchException as e:
            print(f"OpenSearch error: {str(e)}")
            raise
        except Exception as e:
            print(f"Unexpected error in repository: {str(e)}")
            raise