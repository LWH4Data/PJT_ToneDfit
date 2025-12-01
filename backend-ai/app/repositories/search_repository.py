from opensearchpy import OpenSearch, OpenSearchException
from app.libraries.opensearch_client import get_opensearch_client
from app.core.config import settings
from typing import Dict, Any, List
from datetime import datetime, timezone

class SearchRepository:
    def __init__(self):
        self.client: OpenSearch = get_opensearch_client()
        self.index_name = settings.search_index_name
    
    async def upsert_search_keyword(self, keyword: str) -> None:
        """검색어 저장 또는 카운트 증가"""
        try:
            # 검색어를 ID로 사용 (동일 검색어 중복 방지)
            doc_id = keyword.lower().strip()
            
            # update script로 카운트 증가 또는 신규 생성
            body = {
                "script": {
                    "source": """
                        if (ctx._source.containsKey('search_count')) {
                            ctx._source.search_count++;
                            ctx._source.last_searched_at = params.now;
                        } else {
                            ctx._source.search_count = 1;
                            ctx._source.created_at = params.now;
                            ctx._source.last_searched_at = params.now;
                        }
                    """,
                    "params": {
                        "now": datetime.now(timezone.utc).isoformat()
                    }
                },
                "upsert": {
                    "keyword": keyword,
                    "search_count": 1,
                    "created_at": datetime.now(timezone.utc).isoformat(),
                    "last_searched_at": datetime.now(timezone.utc).isoformat()
                }
            }
            
            self.client.update(
                index=self.index_name,
                id=doc_id,
                body=body
            )
            
        except OpenSearchException:
            # 검색어 저장 실패는 치명적이지 않으므로 예외를 던지지 않음
            pass
        except Exception:
            pass
    
    async def get_trending_keywords(self, limit: int = 10) -> List[Dict[str, Any]]:
        """인기 검색어 Top N 조회"""
        try:
            body = {
                "size": limit,
                "query": {
                    "match_all": {}
                },
                "sort": [
                    {"search_count": {"order": "desc"}},
                    {"last_searched_at": {"order": "desc"}}
                ]
            }
            
            response = self.client.search(
                index=self.index_name,
                body=body
            )
            
            results = []
            for idx, hit in enumerate(response['hits']['hits'], start=1):
                source = hit['_source']
                results.append({
                    "rank": idx,
                    "keyword": source['keyword'],
                    "search_count": source['search_count']
                })
            
            return results
            
        except OpenSearchException as e:
            raise
        except Exception as e:
            raise