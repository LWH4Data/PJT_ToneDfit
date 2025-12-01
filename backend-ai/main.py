from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import products, search, chatbot, image_search, character_outfit, calendar
from app.libraries.opensearch_client import get_opensearch_client 
from app.libraries.embedding_model import get_embedding_model
from app.libraries.llm_client import get_llm
from app.libraries.image_embedding_model import get_image_embedding_model

@asynccontextmanager
async def lifespan(app: FastAPI):
    get_opensearch_client()  # OpenSearch 클라이언트 초기화
    get_embedding_model()  # 텍스트 임베딩 모델 초기화
    get_llm()  # LLM 클라이언트 초기화
    get_image_embedding_model()  # 이미지 임베딩 모델 초기화
    yield   # 앱 실행

app = FastAPI(
    title="상품 검색 및 RAG 챗봇 API",
    description="의류를 검색하고 인기 검색어를 반환하며, RAG 기반 챗봇을 제공하는 API",
    version="2.0.0",
    lifespan=lifespan
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 origin 허용 (개발용)
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용
    allow_headers=["*"],  # 모든 헤더 허용
)

# 라우터 등록
app.include_router(products.router, prefix="/ai/products", tags=["products"])
app.include_router(image_search.router, prefix="/ai/search", tags=["image-search"])
app.include_router(search.router, prefix="/ai/search", tags=["search"])
app.include_router(chatbot.router, prefix="/ai/chatbot", tags=["chatbot"])
app.include_router(character_outfit.router, prefix="/ai/character-outfit", tags=["character-outfit"])
app.include_router(calendar.router, prefix="/ai/calendar", tags=["calendar"])
