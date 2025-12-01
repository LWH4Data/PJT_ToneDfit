"""캘린더 검색 리포지토리"""
from typing import List, Dict, Any
from app.libraries.opensearch_client import get_opensearch_client
from app.core.config import settings
from opensearchpy import OpenSearch


class CalendarRepository:
    """캘린더 검색 관련 데이터베이스 작업"""
    
    def __init__(self):
        self.client: OpenSearch = get_opensearch_client()
        # 이미지 인덱스와 동일한 인덱스 사용
        self.index_name = settings.image_index_name
    
    async def search_by_text_embedding(
        self,
        embedding_vector: List[float],
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        KNN을 사용하여 텍스트 임베딩으로 유사한 상품 검색
        
        Args:
            embedding_vector: 캘린더 텍스트의 임베딩 벡터
            limit: 반환할 결과 수
            
        Returns:
            유사한 상품 결과 리스트
        """
        try:
            # KNN 쿼리 구성 (image_vec 필드 사용)
            query = {
                "size": limit,
                "query": {
                    "knn": {
                        "image_vec": {
                            "vector": embedding_vector,
                            "k": limit
                        }
                    }
                },
                "_source": {
                    "excludes": ["*_vec", "image_vec", "text_vec", "fused_vec", "images.img_vec"]
                }
            }
            
            # OpenSearch에서 검색
            response = self.client.search(
                index=self.index_name,
                body=query
            )
            
            # 디버깅: 첫 번째 결과 출력
            if response['hits']['hits']:
                import json
                print("=== DEBUG: Calendar Search - First OpenSearch Hit ===")
                print(json.dumps(response['hits']['hits'][0], indent=2, ensure_ascii=False))
            
            # 결과 파싱 및 중복 제거
            results = []
            seen_product_ids = set()
            
            for hit in response['hits']['hits']:
                source = hit['_source']
                result = source.copy()
                result['score'] = hit['_score']
                
                # product_id가 없으면 _id 사용
                if 'product_id' not in result:
                    result['product_id'] = hit['_id']
                
                # 중복 제거
                if result['product_id'] not in seen_product_ids:
                    seen_product_ids.add(result['product_id'])
                    results.append(result)
            
            return results
            
        except Exception as e:
            raise Exception(f"Failed to search by calendar text: {str(e)}")
    
    async def check_index_exists(self) -> bool:
        """인덱스가 존재하는지 확인"""
        try:
            return self.client.indices.exists(index=self.index_name)
        except Exception:
            return False
