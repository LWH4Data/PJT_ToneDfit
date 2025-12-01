"""이미지 임베딩 모델 설정"""
from functools import lru_cache
from typing import List
import torch
from PIL import Image
import io
from app.core.config import settings
from sentence_transformers import SentenceTransformer 

try:
    from transformers import CLIPProcessor, CLIPModel
    USE_TRANSFORMERS = True
except ImportError:
    from sentence_transformers import SentenceTransformer
    USE_TRANSFORMERS = False


class ImageEmbeddingModel:
    """이미지 임베딩을 위한 모델 클래스"""
    
    def __init__(self, model_name: str = "clip-ViT-B-32", device: str = "cpu"):
        """
        이미지 임베딩 모델 초기화
        
        Args:
            model_name: 사용할 모델 이름 (기본: clip-ViT-B-32)
            device: 사용할 디바이스 (cpu 또는 cuda)
        """
        self.device = device
        self.model_name = model_name
        
        # laion 모델은 transformers 사용
        if "laion" in model_name.lower() or "openai/clip" in model_name.lower():
            self.processor = CLIPProcessor.from_pretrained(model_name)
            self.model = CLIPModel.from_pretrained(model_name).to(device)
            self.use_transformers = True
        else:
            self.model = SentenceTransformer(model_name, device=device)
            self.use_transformers = False
        
        print(f"Image embedding model loaded: {model_name} on {device}")
    
    def encode_image(self, image_bytes: bytes) -> List[float]:
        """
        이미지를 임베딩 벡터로 변환
        
        Args:
            image_bytes: 이미지 바이트 데이터
            
        Returns:
            임베딩 벡터 (리스트)
        """
        try:
            # 바이트를 PIL Image로 변환
            image = Image.open(io.BytesIO(image_bytes))
            
            # RGB로 변환 (RGBA 등의 경우 대비)
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            if self.use_transformers:
                # transformers CLIP 모델 사용
                inputs = self.processor(images=image, return_tensors="pt").to(self.device)
                with torch.no_grad():
                    image_features = self.model.get_image_features(**inputs)
                # 정규화
                image_features = image_features / image_features.norm(p=2, dim=-1, keepdim=True)
                embedding = image_features.cpu().numpy()[0]
            else:
                # sentence-transformers 사용
                embedding = self.model.encode(image, convert_to_tensor=False)
            
            # numpy array를 list로 변환
            return embedding.tolist()
            
        except Exception as e:
            raise ValueError(f"Failed to encode image: {str(e)}")
    
    def encode_text(self, text: str) -> List[float]:
        """
        텍스트를 임베딩 벡터로 변환 (CLIP 텍스트 인코더 사용)
        
        Args:
            text: 입력 텍스트
            
        Returns:
            임베딩 벡터 (리스트)
        """
        try:
            if self.use_transformers:
                # transformers CLIP 모델의 텍스트 인코더 사용
                inputs = self.processor(text=[text], return_tensors="pt", padding=True).to(self.device)
                with torch.no_grad():
                    text_features = self.model.get_text_features(**inputs)
                # 정규화
                text_features = text_features / text_features.norm(p=2, dim=-1, keepdim=True)
                embedding = text_features.cpu().numpy()[0]
            else:
                # sentence-transformers 사용
                embedding = self.model.encode(text, convert_to_tensor=False)
            
            # numpy array를 list로 변환
            return embedding.tolist()
            
        except Exception as e:
            raise ValueError(f"Failed to encode text: {str(e)}")
    
    def encode_images_batch(self, images_bytes: List[bytes]) -> List[List[float]]:
        """
        여러 이미지를 배치로 임베딩
        
        Args:
            images_bytes: 이미지 바이트 데이터 리스트
            
        Returns:
            임베딩 벡터 리스트
        """
        try:
            images = []
            for img_bytes in images_bytes:
                image = Image.open(io.BytesIO(img_bytes))
                if image.mode != 'RGB':
                    image = image.convert('RGB')
                images.append(image)
            
            # 배치 임베딩 생성
            embeddings = self.model.encode(images, convert_to_tensor=False, batch_size=len(images))
            
            # numpy array를 list로 변환
            return [emb.tolist() for emb in embeddings]
            
        except Exception as e:
            raise ValueError(f"Failed to encode images batch: {str(e)}")


@lru_cache(maxsize=1)
def get_image_embedding_model() -> ImageEmbeddingModel:
    """이미지 임베딩 모델 싱글톤 인스턴스 반환"""
    # 설정에서 모델명과 디바이스 가져오기
    device = settings.image_embedding_device
    # cuda 사용 가능 여부 체크
    if device == "cuda" and not torch.cuda.is_available():
        device = "cpu"
        print("CUDA not available, using CPU instead")
    
    return ImageEmbeddingModel(
        model_name=settings.image_embedding_model_name,
        device=device
    )
