"""이미지 검색 API 엔드포인트"""
from functools import lru_cache
from fastapi import APIRouter, Depends, File, UploadFile, Query, HTTPException
from app.services.image_search_service import ImageSearchService
from app.schemas.image_search_response import ImageSearchResponse

router = APIRouter()


@lru_cache(maxsize=1)
def get_image_search_service() -> ImageSearchService:
    """이미지 검색 서비스 인스턴스 반환"""
    return ImageSearchService()


@router.post("/image", response_model=ImageSearchResponse)
async def search_by_image(
    file: UploadFile = File(..., description="검색할 이미지 파일"),
    limit: int = Query(default=10, ge=1, le=100, description="반환할 결과 수"),
    service: ImageSearchService = Depends(get_image_search_service)
):
    """
    이미지로 유사한 상품 검색
    
    - **file**: 업로드할 이미지 파일 (jpg, jpeg, png 등)
    - **limit**: 반환할 최대 결과 수 (기본값: 10, 최대: 100)
    
    Returns:
        유사한 상품 리스트 (유사도 점수 포함)
    """
    # 파일 유효성 검사
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400,
            detail="Invalid file type. Please upload an image file."
        )
    
    # 파일 크기 제한 (예: 10MB)
    max_file_size = 10 * 1024 * 1024  # 10MB
    contents = await file.read()
    
    if len(contents) > max_file_size:
        raise HTTPException(
            status_code=400,
            detail=f"File size exceeds maximum limit of {max_file_size // (1024*1024)}MB"
        )
    
    # 이미지 검색 수행
    result = await service.search_by_image(
        image_bytes=contents,
        limit=limit
    )
    
    return result


@router.get("/health")
async def health_check(
    service: ImageSearchService = Depends(get_image_search_service)
):
    """이미지 검색 서비스 헬스 체크"""
    try:
        index_exists = await service.repository.check_index_exists()
        return {
            "status": "healthy" if index_exists else "index_not_found",
            "index_exists": index_exists,
            "service": "image_search"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "service": "image_search"
        }
