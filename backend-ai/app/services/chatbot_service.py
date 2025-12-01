"""챗봇 서비스"""
import re
import httpx
from typing import Any, Optional
from fastapi import HTTPException

from app.repositories.chatbot_repository import ChatbotRepository
from app.services.products_service import ProductsService
from app.libraries.rag_chain import (
    get_rag_chain,
    create_formatted_prompt
)
from app.schemas.chatbot_request import ChatRequest
from app.schemas.chatbot_response import ChatResponse, Product


def remove_markdown_formatting(text: str) -> str:
    """
    텍스트에서 마크다운 특수문자 제거

    Args:
        text: 원본 텍스트

    Returns:
        특수문자가 제거된 텍스트
    """
    # ** 볼드 제거
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)
    # * 이탤릭 제거
    text = re.sub(r'\*([^*]+)\*', r'\1', text)
    # __ 볼드 제거
    text = re.sub(r'__([^_]+)__', r'\1', text)
    # _ 이탤릭 제거
    text = re.sub(r'_([^_]+)_', r'\1', text)
    # ## 헤더 제거
    text = re.sub(r'^#+\s+', '', text, flags=re.MULTILINE)
    # ` 코드 제거
    text = re.sub(r'`([^`]+)`', r'\1', text)
    # ~~취소선~~ 제거
    text = re.sub(r'~~([^~]+)~~', r'\1', text)

    return text


class ChatbotService:
    """챗봇 비즈니스 로직 (Stateless)"""

    # 카테고리 키워드 매핑
    CATEGORY_KEYWORDS = {
        "아우터": ["아우터", "코트", "패딩", "자켓", "점퍼", "재킷", "무스탕", "야상", "블루종"],
        "상의": ["상의", "티셔츠", "셔츠", "니트", "맨투맨", "후드", "블라우스", "스웨터"],
        "하의": ["하의", "바지", "팬츠", "청바지", "데님", "슬렉스", "조거", "슬랙스"],
        "원피스/스커트": ["원피스", "스커트", "드레스"],
    }

    SMALL_CATEGORY_KEYWORDS = {
        "패딩": ["패딩"],
        "코트": ["코트"],
        "반소매 티셔츠": ["반팔", "반소매"],
        "긴소매 티셔츠": ["긴팔", "긴소매"],
        "후드 티셔츠": ["후드티"],
        "데님 팬츠": ["청바지", "데님"],
        "니트/스웨터": ["니트", "스웨터"],
    }

    # 한국 지역명 영문 매핑
    LOCATION_MAPPING = {
        "서울": "Seoul",
        "부산": "Busan",
        "대구": "Daegu",
        "인천": "Incheon",
        "광주": "Gwangju",
        "대전": "Daejeon",
        "울산": "Ulsan",
        "세종": "Sejong",
        "경기": "Gyeonggi",
        "강원": "Gangwon",
        "충북": "Chungcheongbuk",
        "충남": "Chungcheongnam",
        "전북": "Jeollabuk",
        "전남": "Jeollanam",
        "경북": "Gyeongsangbuk",
        "경남": "Gyeongsangnam",
        "제주": "Jeju",
        "수원": "Suwon",
        "성남": "Seongnam",
        "고양": "Goyang",
        "용인": "Yongin",
        "청주": "Cheongju",
        "천안": "Cheonan",
        "전주": "Jeonju",
        "포항": "Pohang",
        "창원": "Changwon",
    }

    def __init__(self):
        self.repository = ChatbotRepository()
        self.products_service = ProductsService()
        self.rag_chain = get_rag_chain()

    def _extract_location(self, user_message: str) -> str:
        """
        사용자 메시지에서 지역명 추출

        Args:
            user_message: 사용자 메시지

        Returns:
            영문 지역명 (기본값: Seoul)
        """
        for korean_loc, english_loc in self.LOCATION_MAPPING.items():
            if korean_loc in user_message:
                return english_loc
        return "Seoul"  # 기본값

    async def _get_weather_info(self, location: str = "Seoul") -> str:
        """
        날씨 정보 가져오기 (wttr.in API 사용)

        Args:
            location: 위치 (기본값: Seoul)

        Returns:
            날씨 정보 문자열
        """
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                # wttr.in API 호출 (한국어, 간단한 형식)
                url = f"https://wttr.in/{location},South_Korea?format=j1&lang=ko"
                response = await client.get(url)

                if response.status_code != 200:
                    return "날씨 정보를 가져올 수 없습니다."

                data = response.json()

                # 현재 날씨 정보 추출
                current = data.get("current_condition", [{}])[0]
                nearest_area = data.get("nearest_area", [{}])[0]

                location_name = nearest_area.get("areaName", [{}])[0].get("value", "대한민국")
                region = nearest_area.get("region", [{}])[0].get("value", "")

                temp_c = current.get("temp_C", "N/A")
                feels_like_c = current.get("FeelsLikeC", "N/A")
                weather_desc = current.get("lang_ko", [{}])[0].get("value", current.get("weatherDesc", [{}])[0].get("value", "N/A"))
                humidity = current.get("humidity", "N/A")
                wind_speed = current.get("windspeedKmph", "N/A")

                weather_info = f"""
현재 날씨 정보 ({location_name}, {region}):
- 현재 기온: {temp_c}°C
- 체감 온도: {feels_like_c}°C
- 날씨 상태: {weather_desc}
- 습도: {humidity}%
- 풍속: {wind_speed}km/h
"""
                return weather_info.strip()

        except Exception as e:
            return f"날씨 정보를 가져오는 중 오류가 발생했습니다: {str(e)}"

    def _extract_search_query(self, user_message: str) -> str:
        """사용자 메시지에서 검색 쿼리 추출"""
        # 간단한 키워드 추출 (실제로는 더 정교한 NLP 사용 가능)
        # 불필요한 조사, 어미 제거
        query = re.sub(r'(추천|검색|찾아|보여|알려|줘|주세요|주시|해줘|해주세요)', '', user_message)
        query = query.strip()
        return query if query else user_message

    def _classify_intent(self, user_message: str) -> str:
        """
        사용자 의도 분류

        Returns:
            - "weather": 날씨 정보 요청
            - "product_search": 상품 검색 요청
            - "trending": 트렌드 정보 요청
            - "styling": 스타일링 조언 요청
            - "general": 일반 질문
        """
        message_lower = user_message.lower()

        # 날씨 정보 요청
        if any(keyword in message_lower for keyword in ["날씨", "기온", "온도", "비", "눈", "맑", "흐림", "체감온도"]):
            return "weather"

        # 트렌드/인기 검색어 요청
        if any(keyword in message_lower for keyword in ["트렌드", "인기", "유행", "요즘"]):
            return "trending"

        # 상품 검색 요청
        if any(keyword in message_lower for keyword in ["추천", "검색", "찾아", "보여", "구매", "사고싶"]):
            return "product_search"

        # 스타일링 조언 요청
        if any(keyword in message_lower for keyword in ["코디", "입어", "어울리", "매치", "스타일"]):
            return "styling"

        # 기본은 상품 검색으로 처리
        return "product_search"

    def _extract_filters(self, user_message: str, apparent_temp: Optional[float] = None) -> dict[str, Any]:
        """사용자 메시지에서 필터 조건 추출"""
        filters = {}

        # 대분류 추출
        for category, keywords in self.CATEGORY_KEYWORDS.items():
            if any(kw in user_message for kw in keywords):
                filters["large_category"] = category
                break

        # 소분류 추출
        for small_cat, keywords in self.SMALL_CATEGORY_KEYWORDS.items():
            if any(kw in user_message for kw in keywords):
                filters["small_category"] = small_cat
                break

        # 가격 범위 추출 (간단한 정규식 사용)
        price_match = re.search(r'(\d+)만원\s*(?:이하|미만|까지)', user_message)
        if price_match:
            filters["max_price"] = int(price_match.group(1)) * 10000

        price_match = re.search(r'(\d+)만원\s*(?:이상|부터|초과)', user_message)
        if price_match:
            filters["min_price"] = int(price_match.group(1)) * 10000

        return filters

    async def chat(self, request: ChatRequest) -> ChatResponse:
        """챗봇 대화 처리 (Stateless)"""
        try:
            # 의도 분류
            intent = self._classify_intent(request.message)

            # 컨텍스트 준비
            products = None
            products_dict = None
            trending_keywords = None
            weather_info = None
            metadata = {"intent": intent}

            # 날씨 정보 조회 (날씨 요청 시)
            if intent == "weather":
                location = self._extract_location(request.message)
                weather_info = await self._get_weather_info(location)
                metadata["weather_requested"] = True
                metadata["location"] = location

            # 인기 검색어 조회 (트렌드 요청 또는 항상 포함)
            if intent in ["trending", "product_search"]:
                trending_keywords = await self.repository.get_trending_keywords(limit=10)

            # 상품 검색 (상품 검색 또는 스타일링 요청)
            if intent in ["product_search", "styling"]:
                search_query = self._extract_search_query(request.message)
                filters = self._extract_filters(request.message, request.apparent_temp)

                metadata["search_query"] = search_query
                metadata["filters"] = filters

                # ProductsService의 하이브리드 검색 활용
                search_params = {
                    "query": search_query,
                    "page": 1,
                    "page_size": 5,
                    "apparent_temp": request.apparent_temp,
                    **filters
                }

                try:
                    products_response = await self.products_service.search_products(search_params)
                    products = products_response.products
                    # RAG 컨텍스트용 dict 리스트로 변환
                    products_dict = [p.model_dump() for p in products]
                except HTTPException as e:
                    # 검색 결과가 없는 경우 빈 리스트로 처리
                    if e.status_code == 404:
                        products = []
                        products_dict = []
                    else:
                        raise

            # 프롬프트 생성
            formatted_prompt = create_formatted_prompt(
                question=request.message,
                products=products_dict,
                trending_keywords=trending_keywords,
                weather_info=weather_info
            )

            # RAG 체인 실행 (대화 히스토리 없이)
            response_message = await self.rag_chain.ainvoke({
                "formatted_prompt": formatted_prompt,
                "chat_history": []  # 빈 리스트로 전달
            })

            # 마크다운 특수문자 제거
            response_message = remove_markdown_formatting(response_message)

            # 응답 생성
            product_list = None
            if products:
                product_list = [
                    Product(
                        product_id=p.product_id,
                        product_url=p.product_url,
                        name=p.name,
                        brand=p.brand,
                        original_price=p.original_price,
                        representative_image_url=p.representative_image_url
                    )
                    for p in products[:5]  # 최대 5개
                ]

            return ChatResponse(
                message=response_message,
                products=product_list,
                metadata=metadata
            )

        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"챗봇 처리 실패: {str(e)}"
            )
