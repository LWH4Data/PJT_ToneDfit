"""이미지 검색 응답 스키마"""
from pydantic import BaseModel, Field
from typing import List


class ImageSearchResult(BaseModel):
    """이미지 검색 결과 개별 아이템"""
    
    product_id: str = Field(description="상품 ID")
    score: float = Field(description="유사도 점수")
    product_url: str | None = Field(default=None, description="상품 URL")
    name: str | None = Field(default=None, description="상품명")
    brand: str | None = Field(default=None, description="브랜드")
    gender: str | None = Field(default=None, description="성별")
    large_category: str | None = Field(default=None, description="대분류")
    small_category: str | None = Field(default=None, description="소분류")
    colors: List[str] | None = Field(default=None, description="색상 목록")
    fabrics: List[str] | None = Field(default=None, description="소재 목록")
    sizes: List[str] | None = Field(default=None, description="사이즈 목록")
    original_price: int | None = Field(default=None, description="원가")
    representative_image_url: str | None = Field(default=None, description="대표 이미지 URL")
    
    class Config:
        json_schema_extra = {
            "example": {
                "product_id": "P123456",
                "score": 0.95,
                "product_url": "https://example.com/product/123456",
                "name": "화이트 티셔츠",
                "brand": "BrandName",
                "gender": "남성",
                "large_category": "상의",
                "small_category": "반팔티셔츠",
                "colors": ["화이트", "블랙"],
                "fabrics": ["면"],
                "sizes": ["S", "M", "L"],
                "original_price": 29900,
                "representative_image_url": "https://example.com/image.jpg"
            }
        }


class ImageSearchResponse(BaseModel):
    """이미지 검색 응답 모델"""
    
    timestamp: str = Field(description="검색 시간")
    total: int = Field(description="검색된 총 결과 수")
    results: List[ImageSearchResult] = Field(description="검색 결과 리스트")
    
    class Config:
        json_schema_extra = {
            "example": {
                "timestamp": "2024-01-01T12:00:00+09:00",
                "total": 10,
                "results": [
                    {
                        "product_id": "P123456",
                        "score": 0.95,
                        "product_url": "https://example.com/product/123456",
                        "name": "화이트 티셔츠",
                        "brand": "BrandName",
                        "gender": "남성",
                        "large_category": "상의",
                        "small_category": "반팔티셔츠",
                        "colors": ["화이트", "블랙"],
                        "fabrics": ["면"],
                        "sizes": ["S", "M", "L"],
                        "original_price": 29900,
                        "representative_image_url": "https://example.com/image.jpg"
                    }
                ]
            }
        }
