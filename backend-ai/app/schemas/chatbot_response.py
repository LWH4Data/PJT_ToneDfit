"""챗봇 응답 스키마"""
from pydantic import BaseModel, Field
from typing import List, Optional, Any
from datetime import datetime

class Product(BaseModel):
    """상품 정보 (간략)"""
    product_id: str
    product_url: str
    name: str
    brand: str
    original_price: int
    representative_image_url: str

class ChatResponse(BaseModel):
    """챗봇 대화 응답"""
    message: str = Field(..., description="챗봇 응답 메시지")
    products: Optional[List[Product]] = Field(None, description="추천 상품 목록 (있을 경우)")
    metadata: Optional[dict[str, Any]] = Field(None, description="추가 메타데이터 (검색 쿼리, 필터 등)")
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat(), description="응답 시간")

    class Config:
        json_schema_extra = {
            "example": {
                "message": "겨울에 입기 좋은 따뜻한 코트를 추천드립니다. 다음과 같은 상품들이 있습니다.",
                "products": [
                    {
                        "product_id": "PROD123",
                        "name": "울 블렌드 롱 코트",
                        "brand": "ZARA",
                        "original_price": 159000,
                        "representative_image_url": "https://example.com/coat.jpg"
                    }
                ],
                "metadata": {
                    "intent": "product_search",
                    "search_query": "코트",
                    "filters": {"large_category": "아우터"}
                },
                "timestamp": "2024-11-10T12:00:00"
            }
        }
