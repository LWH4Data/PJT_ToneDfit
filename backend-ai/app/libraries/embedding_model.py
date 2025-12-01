"""임베딩 모델 설정"""
from functools import lru_cache
from sentence_transformers import SentenceTransformer
from app.core.config import settings

@lru_cache(maxsize=1)
def get_embedding_model() -> SentenceTransformer:
    return SentenceTransformer(
        settings.embedding_model_name,
        device=settings.embedding_device
    )