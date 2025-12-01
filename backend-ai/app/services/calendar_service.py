"""캘린더 검색 서비스"""
from datetime import datetime
from zoneinfo import ZoneInfo
from fastapi import HTTPException
from typing import List
from app.repositories.calendar_repository import CalendarRepository
from app.libraries.image_embedding_model import get_image_embedding_model
from app.schemas.calendar_response import CalendarSearchResponse, CalendarSearchResult


class CalendarService:
    """캘린더 검색 관련 비즈니스 로직"""
    
    def __init__(self):
        self.repository = CalendarRepository()
        # CLIP 모델 사용 (텍스트 인코더)
        self.embedding_model = get_image_embedding_model()
    
    async def search_by_calendar_text(
        self,
        text: str,
        limit: int = 10
    ) -> CalendarSearchResponse:
        """
        캘린더 텍스트로 유사한 상품 검색
        
        Args:
            text: 캘린더 텍스트 (날씨 느낌 + 사용자 메모)
            limit: 반환할 결과 수
            
        Returns:
            캘린더 검색 결과
        """
        try:
            # 1. 인덱스 존재 확인
            index_exists = await self.repository.check_index_exists()
            if not index_exists:
                raise HTTPException(
                    status_code=503,
                    detail="Calendar search index is not available"
                )
            
            # 2. 텍스트를 임베딩 벡터로 변환 (CLIP 텍스트 인코더 사용)
            try:
                embedding_vector = self.embedding_model.encode_text(text)
            except Exception as e:
                raise HTTPException(
                    status_code=400,
                    detail=f"Failed to encode text: {str(e)}"
                )
            
            # 3. OpenSearch에서 유사한 상품 검색 (KNN)
            search_results = await self.repository.search_by_text_embedding(
                embedding_vector=embedding_vector,
                limit=limit
            )
            
            # 4. 결과가 없는 경우
            if not search_results:
                return CalendarSearchResponse(
                    timestamp=datetime.now(ZoneInfo("Asia/Seoul")).isoformat(),
                    total=0,
                    results=[]
                )
            
            # 5. Response 객체 생성
            results = [
                CalendarSearchResult(**item)
                for item in search_results
            ]
            
            return CalendarSearchResponse(
                timestamp=datetime.now(ZoneInfo("Asia/Seoul")).isoformat(),
                total=len(results),
                results=results
            )
            
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to search by calendar text: {str(e)}"
            )
