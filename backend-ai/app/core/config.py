from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8"
    )

    # OpenSearch 세팅
    opensearch_host: str
    opensearch_port: int
    products_index_name: str
    search_index_name: str
    image_index_name: str = "product_images"  # 이미지 검색 인덱스

    # 임베딩 모델 세팅
    embedding_model_name: str
    embedding_device: str
    
    # 이미지 임베딩 모델 세팅
    image_embedding_model_name: str = "clip-ViT-B-32"
    image_embedding_device: str = "cpu"

    # Gemini 및 llm 세팅
    gemini_api_key: str
    gemini_model_name: str
    llm_temperature: float
    llm_max_tokens: int

settings = Settings()