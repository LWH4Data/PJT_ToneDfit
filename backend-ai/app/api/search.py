from functools import lru_cache
from fastapi import APIRouter, Depends, Query
from app.services.search_service import SearchService
from app.schemas.search_response import TrendingSearchResponse

router = APIRouter()

@lru_cache(maxsize=1)
def get_search_service() -> SearchService:
    return SearchService()

@router.get("/trending", response_model=TrendingSearchResponse)
async def get_trending_searches(
    limit: int = Query(default=10, ge=1, le=50),
    service: SearchService = Depends(get_search_service)
):
    """인기 검색어 조회"""
    results = await service.get_trending_searches(limit)
    return results