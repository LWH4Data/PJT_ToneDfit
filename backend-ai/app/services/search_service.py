from app.repositories.search_repository import SearchRepository
from app.schemas.search_response import TrendingSearchResponse, TrendingSearchKeyword
from fastapi import HTTPException
from datetime import datetime
from zoneinfo import ZoneInfo

class SearchService:
    """검색어 관련 비즈니스 로직"""
    
    def __init__(self):
        self.repository = SearchRepository()
    
    async def log_search_keyword(self, keyword: str | None) -> None:
        """검색어 기록 (빈 문자열이나 None은 무시)"""
        if not keyword or not keyword.strip():
            return
        
        try:
            await self.repository.upsert_search_keyword(keyword.strip())
        except Exception:
            # 검색어 로깅 실패는 사용자 경험에 영향 없음
            pass
    
    async def get_trending_searches(self, limit: int = 10) -> TrendingSearchResponse:
        """인기 검색어 조회"""
        try:
            # Repository에서 데이터 가져오기
            trending_data = await self.repository.get_trending_keywords(limit)
            
            # NOT FOUND 처리
            if not trending_data:
                raise HTTPException(
                    status_code=404,
                    detail="No trending keywords found"
                )
            
            # Response 객체 생성
            keywords = [
                TrendingSearchKeyword(
                    rank=item['rank'],
                    keyword=item['keyword'],
                    search_count=item['search_count']
                )
                for item in trending_data
            ]
            
            return TrendingSearchResponse(
                timestamp=datetime.now(ZoneInfo("Asia/Seoul")).isoformat(),
                keywords=keywords
            )
            
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to get trending searches: {str(e)}"
            )