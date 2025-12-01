"""캐릭터 옷 입히기 응답 스키마"""
from pydantic import BaseModel, Field


class CharacterOutfitResponse(BaseModel):
    """캐릭터 옷 입히기 응답 모델"""
    
    timestamp: str = Field(description="생성 시간")
    image_url: str = Field(description="생성된 이미지 URL (배경 제거된 버전)")
    original_image_url: str | None = Field(default=None, description="원본 이미지 URL (배경 포함)")
    message: str = Field(default="이미지 생성 완료", description="응답 메시지")
    
    class Config:
        json_schema_extra = {
            "example": {
                "timestamp": "2024-01-01T12:00:00",
                "image_url": "https://example.com/edited_0_nobg.png",
                "original_image_url": "https://example.com/edited_0.png",
                "message": "이미지 생성 완료"
            }
        }
