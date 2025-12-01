from functools import lru_cache
from fastapi import APIRouter, HTTPException
from app.schemas.chatbot_request import ChatRequest
from app.schemas.chatbot_response import ChatResponse
from app.services.chatbot_service import ChatbotService

router = APIRouter()

@lru_cache(maxsize=1)
def get_chatbot_service() -> ChatbotService:
    return ChatbotService()

@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest) -> ChatResponse:
    """
    RAG 기반 패션 챗봇 API (Stateless)

    - **message**: 사용자 메시지 (필수)
    - **apparent_temp**: 체감온도 (선택, 날씨 기반 추천 시 사용)

    ### 기능
    1. 의류 검색 도움: 자연어 질문을 검색 쿼리로 변환하여 상품 추천
    2. 스타일링 조언: 날씨, 상황에 맞는 코디 제안
    3. 상품 정보 Q&A: 검색된 상품에 대한 질문 답변
    4. 트렌드 정보 제공: 인기 검색어 기반 트렌드 안내

    ### 응답
    - **message**: AI 응답 메시지
    - **products**: 추천 상품 목록 (있을 경우)
    - **metadata**: 검색 의도, 쿼리, 필터 등 메타데이터
    """
    chatbot_service = get_chatbot_service()

    try:
        return await chatbot_service.chat(request)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"챗봇 요청 처리 실패: {str(e)}"
        )
