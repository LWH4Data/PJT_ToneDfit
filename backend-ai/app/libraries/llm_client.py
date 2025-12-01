"""LangChain LLM 클라이언트 설정 (Google Gemini)"""
from functools import lru_cache
from langchain_google_genai import ChatGoogleGenerativeAI
from app.core.config import settings

@lru_cache(maxsize=1)
def get_llm() -> ChatGoogleGenerativeAI:
    """Google Gemini LLM 클라이언트 반환"""
    return ChatGoogleGenerativeAI(
        model=settings.gemini_model_name,
        google_api_key=settings.gemini_api_key,
        temperature=settings.llm_temperature,
        max_output_tokens=settings.llm_max_tokens,
    )
