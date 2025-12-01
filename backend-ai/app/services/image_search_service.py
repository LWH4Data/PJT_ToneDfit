"""이미지 검색 서비스"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import HTTPException
from typing import List
from app.repositories.image_search_repository import ImageSearchRepository
from app.libraries.image_embedding_model import get_image_embedding_model
from app.schemas.image_search_response import ImageSearchResponse, ImageSearchResult


class ImageSearchService:
    """이미지 검색 관련 비즈니스 로직"""
    
    def __init__(self):
        self.repository = ImageSearchRepository()
        self.embedding_model = get_image_embedding_model()
    
    async def search_by_image(
        self,
        image_bytes: bytes,
        limit: int = 10
    ) -> ImageSearchResponse:
        """
        이미지로 유사한 상품 검색
        
        Args:
            image_bytes: 업로드된 이미지 바이트 데이터
            limit: 반환할 결과 수
            
        Returns:
            이미지 검색 결과
        """
        try:
            # 1. 인덱스 존재 확인
            index_exists = await self.repository.check_index_exists()
            if not index_exists:
                raise HTTPException(
                    status_code=503,
                    detail="Image search index is not available"
                )
            
            # 2. 이미지를 임베딩 벡터로 변환
            try:
                embedding_vector = self.embedding_model.encode_image(image_bytes)
            except ValueError as e:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid image format: {str(e)}"
                )
            
            # 3. OpenSearch에서 유사한 이미지 검색 (KNN)
            search_results = await self.repository.search_similar_images(
                embedding_vector=embedding_vector,
                limit=limit
            )
            
            # 4. 결과가 없는 경우
            if not search_results:
                return ImageSearchResponse(
                    timestamp=datetime.now(ZoneInfo("Asia/Seoul")).isoformat(),
                    total=0,
                    results=[]
                )
            
            # 5. Response 객체 생성
            results = [
                ImageSearchResult(**item)
                for item in search_results
            ]
            
            return ImageSearchResponse(
                timestamp=datetime.now(ZoneInfo("Asia/Seoul")).isoformat(),
                total=len(results),
                results=results
            )
            
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to search by image: {str(e)}"
            )
