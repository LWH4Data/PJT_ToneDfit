"""챗봇 RAG를 위한 리포지토리"""
from typing import Any
from app.libraries.opensearch_client import get_opensearch_client
from app.core.config import settings

class ChatbotRepository:
    """챗봇 관련 데이터 조회 리포지토리"""

    def __init__(self):
        self.client = get_opensearch_client()
        self.products_index = settings.products_index_name
        self.search_index = settings.search_index_name

    async def get_trending_keywords(self, limit: int = 10) -> list[dict[str, Any]]:
        """
        인기 검색어 조회

        Args:
            limit: 반환할 검색어 개수

        Returns:
            인기 검색어 리스트
        """
        search_body = {
            "size": limit,
            "sort": [
                {"search_count": {"order": "desc"}},
                {"last_searched_at": {"order": "desc"}}
            ],
            "_source": ["keyword", "search_count"]
        }

        response = self.client.search(
            index=self.search_index,
            body=search_body
        )

        keywords = []
        for idx, hit in enumerate(response["hits"]["hits"], 1):
            keywords.append({
                "rank": idx,
                "keyword": hit["_source"]["keyword"],
                "search_count": hit["_source"]["search_count"]
            })

        return keywords
