from pydantic import BaseModel, Field, ConfigDict

class Product(BaseModel):
    product_id: str = Field(alias="productId")
    product_url: str = Field(alias="productUrl")
    brand: str
    gender: str
    large_category: str = Field(alias="largeCategory")
    small_category: str = Field(alias="smallCategory")
    name: str
    original_price: int = Field(alias="originalPrice")
    colors: list[str]
    fabrics: list[str]
    sizes: list[str]
    review_count: int = Field(alias="reviewCount")
    representative_image_url: str = Field(alias="representativeImageUrl")

    model_config = ConfigDict(populate_by_name=True)

class ProductsResponse(BaseModel):
    total: int
    page: int
    size: int
    products: list[Product]

    model_config = ConfigDict(
        json_schema_extra={
            "examples": [
                {
                    "total": 2,
                    "page": 1,
                    "size": 20,
                    "products": [
                        {
                            "productId": "PROD001",
                            "productUrl": "https://example.com/product/001",
                            "brand": "Nike",
                            "gender": "남성",
                            "largeCategory": "상의",
                            "smallCategory": "반소매 티셔츠",
                            "name": "나이키 드라이핏 티셔츠",
                            "originalPrice": 45000,
                            "colors": ["검정", "흰색"],
                            "fabrics": ["기능성"],
                            "sizes": ["S", "M", "L"],
                            "reviewCount": 23,
                            "representativeImageUrl": "https://example.com/images/001.jpg"
                        },
                        {
                            "productId": "PROD002",
                            "productUrl": "https://example.com/product/002",
                            "brand": "Adidas",
                            "gender": "남성",
                            "largeCategory": "하의",
                            "smallCategory": "트레이닝 바지",
                            "name": "아디다스 트랙 팬츠",
                            "originalPrice": 65000,
                            "colors": ["네이비"],
                            "fabrics": ["폴리에스테르"],
                            "sizes": ["FREE"],
                            "reviewCount": 457,
                            "representativeImageUrl": "https://example.com/images/002.jpg"
                        }
                    ]
                }
            ]
        }
    )