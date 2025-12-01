"""챗봇 요청 스키마"""
from pydantic import BaseModel, Field
from typing import Optional

class ChatRequest(BaseModel):
    """챗봇 대화 요청"""
    message: str = Field(..., description="사용자 메시지", min_length=1)
    apparent_temp: Optional[float] = Field(None, description="체감온도 (날씨 기반 추천용)")

    class Config:
        json_schema_extra = {
            "example": {
                "message": "겨울에 입을 따뜻한 코트 추천해줘",
                "apparent_temp": 5.0
            }
        }
