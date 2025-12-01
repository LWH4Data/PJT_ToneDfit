"""캘린더 검색 API 엔드포인트"""
from functools import lru_cache
from fastapi import APIRouter, Depends, HTTPException
from app.services.calendar_service import CalendarService
from app.schemas.calendar_request import CalendarRequest
from app.schemas.calendar_response import CalendarSearchResponse

router = APIRouter()


@lru_cache(maxsize=1)
def get_calendar_service() -> CalendarService:
    """캘린더 검색 서비스 인스턴스 반환"""
    return CalendarService()


@router.post("", response_model=CalendarSearchResponse)
async def search_by_calendar(
    request: CalendarRequest,
    service: CalendarService = Depends(get_calendar_service)
):
    """
    캘린더 텍스트로 유사한 상품 검색
    
    사용자가 캘린더에 기록한 날씨 느낌과 메모를 바탕으로 
    적합한 의류 상품을 추천합니다.
    
    - **text**: 캘린더 텍스트 (예: "추움 오늘 회의가 있어서 정장을 입어야 해")
    - **limit**: 반환할 최대 결과 수 (기본값: 10, 최대: 100)
    
    Returns:
        유사한 상품 리스트 (유사도 점수 포함)
    """
    # 텍스트 유효성 검사
    if not request.text or not request.text.strip():
        raise HTTPException(
            status_code=400,
            detail="Text cannot be empty"
        )
    
    # 캘린더 검색 수행
    result = await service.search_by_calendar_text(
        text=request.text.strip(),
        limit=request.limit
    )
    
    return result


@router.get("/health")
async def health_check(
    service: CalendarService = Depends(get_calendar_service)
):
    """캘린더 검색 서비스 헬스 체크"""
    try:
        index_exists = await service.repository.check_index_exists()
        return {
            "status": "healthy" if index_exists else "index_not_found",
            "index_exists": index_exists,
            "service": "calendar_search"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "service": "calendar_search"
        }
