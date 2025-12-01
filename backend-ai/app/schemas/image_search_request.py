"""이미지 검색 요청 스키마"""
from pydantic import BaseModel, Field


class ImageSearchRequest(BaseModel):
    """이미지 검색 요청 모델"""
    
    limit: int = Field(
        default=10,
        ge=1,
        le=100,
        description="반환할 결과 수"
    )
    
    class Config:
        json_schema_extra = {
            "example": {
                "limit": 10
            }
        }
