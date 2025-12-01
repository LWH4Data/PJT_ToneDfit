"""캘린더 검색 요청 스키마"""
from pydantic import BaseModel, Field


class CalendarRequest(BaseModel):
    """캘린더 검색 요청 모델"""
    
    text: str = Field(
        description="캘린더 텍스트 (날씨 느낌 + 사용자 메모)",
        min_length=1
    )
    limit: int = Field(
        default=10,
        ge=1,
        le=100,
        description="반환할 결과 수"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "text": "추움 오늘 회의가 있어서 정장을 입어야 해",
                "limit": 10
            }
        }
