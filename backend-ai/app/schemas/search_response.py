from pydantic import BaseModel, Field, ConfigDict

class TrendingSearchKeyword(BaseModel):
    rank: int
    keyword: str
    search_count: int = Field(alias="searchCount")
    
    model_config = ConfigDict(populate_by_name=True)

class TrendingSearchResponse(BaseModel):
    timestamp: str
    keywords: list[TrendingSearchKeyword]

    model_config = ConfigDict(
        json_schema_extra={
            "examples": [
                {
                    "timestamp": "2025-11-10T15:30:00Z",
                    "keywords": [
                        {
                            "rank": 1,
                            "keyword": "반팔 티셔츠",
                            "searchCount": 523
                        },
                        {
                            "rank": 2,
                            "keyword": "패딩",
                            "searchCount": 401
                        },
                        {
                            "rank": 3,
                            "keyword": "청바지",
                            "searchCount": 387
                        },
                        {
                            "rank": 4,
                            "keyword": "나이키 운동화",
                            "searchCount": 312
                        },
                        {
                            "rank": 5,
                            "keyword": "코트",
                            "searchCount": 289
                        },
                        {
                            "rank": 6,
                            "keyword": "맨투맨",
                            "searchCount": 256
                        },
                        {
                            "rank": 7,
                            "keyword": "후드티",
                            "searchCount": 234
                        },
                        {
                            "rank": 8,
                            "keyword": "슬랙스",
                            "searchCount": 198
                        },
                        {
                            "rank": 9,
                            "keyword": "원피스",
                            "searchCount": 176
                        },
                        {
                            "rank": 10,
                            "keyword": "스니커즈",
                            "searchCount": 165
                        }
                    ]
                }
            ]
        }
    )