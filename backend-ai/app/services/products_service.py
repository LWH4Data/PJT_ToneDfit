import logging
from fastapi import HTTPException
from typing import Any
from app.repositories.products_repository import ProductsRepository
from app.schemas.products_response import ProductsResponse
from app.libraries.embedding_model import get_embedding_model

logger = logging.getLogger(__name__)


class ProductsService:
    """상품 검색 비즈니스 로직을 처리하는 서비스"""
    
    # 상수 정의
    DEFAULT_PAGE_SIZE = 20
    MAX_PAGE_SIZE = 100
    DEFAULT_KNN_K = 100
    
    def __init__(self):
        self.repository = ProductsRepository()
    
    def _build_filter_conditions(self, params: dict) -> list[dict[str, Any]]:
        """필터 조건 생성"""
        must_conditions = []

        # 브랜드
        if params.get('brand'):
            must_conditions.append({'terms': {'brand': params['brand']}})

        # 성별
        if params.get('gender'):
            must_conditions.append({'term': {'gender': params['gender']}})

        # 대분류
        if params.get('large_category'):
            must_conditions.append({'term': {'large_category': params['large_category']}})

        # 소분류
        if params.get('small_category'):
            must_conditions.append({'term': {'small_category': params['small_category']}})

        # 가격 범위
        min_price = params.get('min_price')
        max_price = params.get('max_price')
        if min_price is not None or max_price is not None:
            price_range = {}
            if min_price is not None:
                price_range['gte'] = min_price
            if max_price is not None:
                price_range['lte'] = max_price
            must_conditions.append({'range': {'original_price': price_range}})

        # 색상
        if params.get('colors'):
            must_conditions.append({'terms': {'colors': params['colors']}})

        # 소재
        if params.get('fabrics'):
            must_conditions.append({'terms': {'fabrics': params['fabrics']}})

        # 사이즈
        if params.get('sizes'):
            must_conditions.append({'terms': {'sizes': params['sizes']}})

        return must_conditions

    def _build_text_search_query(self, query_text: str) -> dict[str, Any]:
        """BM25 텍스트 검색 쿼리 생성"""
        return {
            "multi_match": {
                "query": query_text,
                "fields": [
                    "name^3",
                    "brand^2",
                    "gender",
                    "large_category",
                    "small_category^2",
                    "colors",
                    "fabrics",
                    "sizes"
                ],
                "type": "best_fields",
                "fuzziness": "AUTO"
            }
        }

    def _build_vector_search_query(self, query_text: str) -> dict[str, Any] | None:
        """벡터 검색 쿼리 생성 (knn query 방식)"""
        try:
            embedding_model = get_embedding_model()
            embedding_vector = embedding_model.encode(query_text).tolist()

            return {
                "knn": {
                    "embedding": {
                        "vector": embedding_vector,
                        "k": self.DEFAULT_KNN_K
                    }
                }
            }
        except Exception as e:
            logger.error(f"벡터 임베딩 실패: {e}", exc_info=True)
            return None

    def _build_weather_boost_conditions(self, apparent_temp: float) -> list[dict[str, Any]]:
        """체감온도 기반 부스팅 조건 생성"""
        functions = []
        
        # 매우 추운 날씨 (5도 미만) - 겨울 한파
        if apparent_temp < 5:
            functions.extend([
                {"filter": {"term": {"large_category": "아우터"}}, "weight": 3.0},
                {"filter": {"terms": {"small_category": ["패딩", "코트", "무스탕/퍼"]}}, "weight": 3.5},
                {"filter": {"terms": {"fabrics": ["울", "캐시미어", "알파카"]}}, "weight": 2.0},
                {"filter": {"terms": {"colors": ["블랙", "차콜", "그레이", "네이비", "브라운", "카멜"]}}, "weight": 1.2}
            ])
        
        # 추운 날씨 (5-10도) - 초겨울/늦가을
        elif apparent_temp < 10:
            functions.extend([
                {"filter": {"term": {"large_category": "아우터"}}, "weight": 2.8},
                {"filter": {"terms": {"small_category": ["코트", "패딩", "무스탕/퍼", "플리스/카디건", "블루종/MA-1/야상"]}}, "weight": 3.0},
                {"filter": {"terms": {"small_category": ["니트/스웨터", "후드 집업", "맨투맨/스웨트", "후드 티셔츠"]}}, "weight": 2.2},
                {"filter": {"terms": {"fabrics": ["울", "아크릴", "트위드"]}}, "weight": 1.8},
                {"filter": {"terms": {"small_category": ["데님 팬츠", "코튼 팬츠", "슈트 팬츠/슬렉스"]}}, "weight": 1.5}
            ])
        
        # 쌀쌀한 날씨 (10-15도) - 가을/초봄
        elif apparent_temp < 15:
            functions.extend([
                {"filter": {"terms": {"small_category": ["플리스/카디건", "재킷/블레이저", "레더/라이더스", "블루종/MA-1/야상", "후드 집업", "베스트"]}}, "weight": 2.8},
                {"filter": {"terms": {"small_category": ["니트/스웨터", "맨투맨/스웨트", "후드 티셔츠", "긴소매 티셔츠", "셔츠/블라우스"]}}, "weight": 2.5},
                {"filter": {"terms": {"fabrics": ["면", "폴리에스터", "아크릴", "레이온"]}}, "weight": 1.5},
                {"filter": {"terms": {"small_category": ["데님 팬츠", "코튼 팬츠", "슈트 팬츠/슬렉스", "트레이닝/조거 팬츠"]}}, "weight": 1.5}
            ])
        
        # 선선한 날씨 (15-20도) - 봄/가을
        elif apparent_temp < 20:
            functions.extend([
                {"filter": {"terms": {"small_category": ["재킷/블레이저", "레더/라이더스", "베스트", "후드 집업"]}}, "weight": 1.8},
                {"filter": {"terms": {"small_category": ["셔츠/블라우스", "긴소매 티셔츠", "맨투맨/스웨트", "후드 티셔츠", "니트/스웨터"]}}, "weight": 2.5},
                {"filter": {"terms": {"fabrics": ["면", "폴리에스터", "레이온", "텐셀"]}}, "weight": 1.5},
                {"filter": {"terms": {"small_category": ["데님 팬츠", "코튼 팬츠", "슈트 팬츠/슬렉스"]}}, "weight": 1.5},
                {"filter": {"term": {"large_category": "원피스/스커트"}}, "weight": 1.8}
            ])
        
        # 따뜻한 날씨 (20-25도) - 늦봄/초여름
        elif apparent_temp < 25:
            functions.extend([
                {"filter": {"terms": {"small_category": ["반소매 티셔츠", "긴소매 티셔츠", "셔츠/블라우스", "피케/카라 티셔츠"]}}, "weight": 2.8},
                {"filter": {"terms": {"fabrics": ["면", "린넨", "텐셀", "모달", "레이온"]}}, "weight": 2.0},
                {"filter": {"terms": {"small_category": ["데님 팬츠", "코튼 팬츠", "슈트 팬츠/슬렉스", "숏 팬츠"]}}, "weight": 1.8},
                {"filter": {"term": {"large_category": "원피스/스커트"}}, "weight": 2.2},
                {"filter": {"terms": {"colors": ["화이트", "아이보리", "베이지", "핑크", "블루", "민트", "옐로우", "라벤더"]}}, "weight": 1.3}
            ])
        
        # 더운 날씨 (25-30도) - 여름
        elif apparent_temp < 30:
            functions.extend([
                {"filter": {"terms": {"small_category": ["반소매 티셔츠", "민소매 티셔츠", "피케/카라 티셔츠"]}}, "weight": 3.0},
                {"filter": {"terms": {"fabrics": ["린넨", "면", "텐셀", "모달", "기능성"]}}, "weight": 2.2},
                {"filter": {"terms": {"small_category": ["숏 팬츠", "데님 팬츠", "코튼 팬츠"]}}, "weight": 2.5},
                {"filter": {"terms": {"small_category": ["미니원피스", "미디원피스", "미니스커트", "미디스커트"]}}, "weight": 2.8},
                {"filter": {"terms": {"colors": ["화이트", "아이보리", "베이지", "블루", "민트", "옐로우", "핑크", "오렌지", "라벤더"]}}, "weight": 1.5}
            ])
        
        # 매우 더운 날씨 (30도 이상) - 폭염
        else:
            functions.extend([
                {"filter": {"terms": {"small_category": ["민소매 티셔츠", "반소매 티셔츠"]}}, "weight": 3.5},
                {"filter": {"terms": {"fabrics": ["린넨", "면", "기능성", "텐셀", "모달"]}}, "weight": 2.5},
                {"filter": {"terms": {"small_category": ["숏 팬츠", "레깅스"]}}, "weight": 3.0},
                {"filter": {"terms": {"small_category": ["미니원피스", "미디원피스", "미니스커트"]}}, "weight": 3.0},
                {"filter": {"terms": {"colors": ["화이트", "아이보리", "베이지", "블루", "민트"]}}, "weight": 1.8}
            ])

        return functions

    def _build_hybrid_query(
        self, 
        query_text: str, 
        params: dict
    ) -> dict[str, Any]:
        """하이브리드 검색 쿼리 생성"""
        # 페이지네이션 검증
        page = max(1, int(params.get('page', 1)))
        page_size = min(
            self.MAX_PAGE_SIZE,
            max(1, int(params.get('page_size', self.DEFAULT_PAGE_SIZE)))
        )
        
        filter_conditions = self._build_filter_conditions(params)
        apparent_temp = params.get('apparent_temp')
        
        # 기본 구조
        search_body: dict[str, Any] = {
            "size": page_size,
            "from": (page - 1) * page_size
        }
        
        # === 1. 쿼리가 없는 경우: 날씨 부스팅 + 필터 검색 ===
        if not query_text:
            weather_functions = []
            
            if apparent_temp is not None:
                weather_functions = self._build_weather_boost_conditions(apparent_temp)
            
            # 날씨 부스팅이 있는 경우
            if weather_functions:
                base_query = (
                    {"bool": {"filter": filter_conditions}} 
                    if filter_conditions 
                    else {"match_all": {}}
                )
                
                search_body["query"] = {
                    "function_score": {
                        "query": base_query,
                        "functions": weather_functions,
                        "score_mode": "sum",
                        "boost_mode": "sum"
                    }
                }
            # 날씨 부스팅 없고 필터만 있는 경우
            elif filter_conditions:
                search_body["query"] = {"bool": {"filter": filter_conditions}}
            # 둘 다 없는 경우
            else:
                search_body["query"] = {"match_all": {}}
        
        # === 2. 쿼리가 있는 경우: 하이브리드 검색 ===
        else:
            # 2-1. BM25 텍스트 검색
            text_query = self._build_text_search_query(query_text)
            
            # 2-2. Nested 리뷰 검색
            review_query = {
                "nested": {
                    "path": "reviews",
                    "query": {
                        "bool": {
                            "should": [
                                {"match": {"reviews.content": {"query": query_text, "boost": 1.5}}},
                                {"match": {"reviews.option": {"query": query_text, "boost": 1.0}}}
                            ]
                        }
                    },
                    "score_mode": "avg"
                }
            }
            
            # 2-3. 벡터 검색 준비
            vector_query = self._build_vector_search_query(query_text)
            if vector_query is None:
                logger.warning(f"벡터 검색 스킵 (임베딩 실패): query={query_text}")
            
            # === Should 쿼리 구성 ===
            should_queries = [text_query, review_query]
            
            # 벡터 쿼리를 should에 추가
            if vector_query:
                should_queries.append(vector_query)
            
            # Bool 쿼리 구성
            base_bool_query: dict[str, Any] = {
                "should": should_queries,
                "minimum_should_match": 1
            }
            
            if filter_conditions:
                base_bool_query["filter"] = filter_conditions
            
            # 2-4. 날씨 부스팅
            weather_functions = []
            if apparent_temp is not None:
                weather_functions = self._build_weather_boost_conditions(apparent_temp)
            
            # === 쿼리 조합 ===
            
            # 날씨 부스팅이 있는 경우
            if weather_functions:
                search_body["query"] = {
                    "function_score": {
                        "query": {"bool": base_bool_query},
                        "functions": weather_functions,
                        "score_mode": "sum",
                        "boost_mode": "sum"
                    }
                }
            # 날씨 부스팅 없는 경우
            else:
                search_body["query"] = {"bool": base_bool_query}
        
        return search_body

    def _process_search_results(
        self, 
        response: dict[str, Any],
        page: int,
        page_size: int
    ) -> ProductsResponse:
        """검색 결과를 ProductsResponse로 변환"""
        hits = response['hits']['hits']
        total = response['hits']['total']['value']

        # NOT FOUND 처리
        if total == 0:
            raise HTTPException(
                status_code=404,
                detail="Not found: No products found matching the given params"
            )

        # 상품 데이터 구성
        products = []
        for hit in hits:
            product = hit['_source']
            review_count = len(product.get('reviews', []))
            product['review_count'] = review_count
            products.append(product)

        return ProductsResponse(
            total=total,
            page=page,
            size=page_size,
            products=products
        )

    async def search_products(
        self, 
        params: dict[str, str | int | list[str] | None]
    ) -> ProductsResponse:
        """주어진 파라미터로 상품을 검색"""
        try:
            # 파라미터 추출 (공백 제거)
            query_param = params.get('query')
            query_text = str(query_param).strip() if query_param is not None else ''
            page = int(params.get('page', 1))
            page_size = int(params.get('page_size', self.DEFAULT_PAGE_SIZE))
            
            # 쿼리 빌드
            query_body = self._build_hybrid_query(
                query_text=query_text,
                params=params
            )
            
            # Repository를 통한 검색
            response = await self.repository.search(query_body)
            
            # 결과 처리
            return self._process_search_results(response, page, page_size)

        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Service error: {str(e)}", exc_info=True)
            raise HTTPException(
                status_code=500,
                detail=f"Search failed: {str(e)}"
            )