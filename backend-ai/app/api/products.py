from functools import lru_cache
from fastapi import APIRouter, Depends, Query
from app.services.search_service import SearchService
from app.services.products_service import ProductsService
from app.schemas.products_response import ProductsResponse

router = APIRouter()

@lru_cache(maxsize=1)   # 캐싱으로 서비스 객체 한 번만 생성하고 재사용
def get_products_service() -> ProductsService:
    return ProductsService()

@lru_cache(maxsize=1)
def get_search_service() -> SearchService:
    return SearchService()

@router.get("", response_model=ProductsResponse)
async def search_products(
    # 쿼리 파라미터
    apparent_temp: float | None = Query(default=None, alias="apparentTemp"),
    query: str | None = Query(default=None),
    brand: list[str] | None = Query(default=None),
    gender: str | None = Query(default=None),
    large_category: str | None = Query(default=None, alias="largeCategory"),
    small_category: str | None = Query(default=None, alias="smallCategory"),
    min_price: int | None = Query(default=None, ge=0, alias="minPrice"),
    max_price: int | None = Query(default=None, ge=0, alias="maxPrice"),
    color: list[str] | None = Query(default=None),
    fabric: list[str] | None = Query(default=None),
    size: list[str] | None = Query(default=None),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100, alias="pageSize"),
    service: ProductsService = Depends(get_products_service),
    search_service: SearchService = Depends(get_search_service),
):        
    params = {
        "apparent_temp": apparent_temp,
        "query": query,
        "brand": brand,
        "gender": gender,
        "large_category": large_category,
        "small_category": small_category,
        "min_price": min_price,
        "max_price": max_price,
        "colors": color,
        "fabrics": fabric,
        "sizes": size,
        "page": page,
        "page_size": page_size
    }

    # 검색어 기록 (비동기, 실패해도 검색은 계속)
    if query:
        await search_service.log_search_keyword(query)

    results = await service.search_products(params)
    return results