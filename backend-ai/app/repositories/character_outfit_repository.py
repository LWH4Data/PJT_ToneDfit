"""캐릭터 옷 입히기 리포지토리"""
import io
import os
import re
from datetime import datetime
from PIL import Image as PILImage
from google import genai
from google.genai import types
from app.core.config import settings


# rembg 설치 여부 확인
try:
    from rembg import remove as rembg_remove
    _REMBG_AVAILABLE = True
except Exception:
    _REMBG_AVAILABLE = False


class CharacterOutfitRepository:
    """캐릭터 옷 입히기 처리 리포지토리"""
    
    def __init__(self):
        """Gemini API 클라이언트 초기화"""
        # Gemini API 클라이언트 생성 (settings에서 API 키 사용)
        self.client = genai.Client(api_key=settings.gemini_api_key)
        self.model = "gemini-2.5-flash-image"
        self.output_dir = "temp/generated_images"
        self.character_image_path = "temp/my_character.png"
        
        # 출력 디렉토리 생성
        os.makedirs(self.output_dir, exist_ok=True)
    
    def _bump_suffix(self, path: str) -> str:
        """파일명이 존재하면 뒤 번호를 증가시켜 가용 파일명 반환"""
        root, ext = os.path.splitext(path)
        m = re.match(r"^(.*?)(?:_([0-9]+))$", root)
        
        if not os.path.exists(path):
            return path
        
        if m:
            base = m.group(1)
            n = int(m.group(2))
        else:
            base = root
            n = 0
        
        while True:
            candidate = f"{base}_{n}{ext}"
            if not os.path.exists(candidate):
                return candidate
            n += 1
    
    def _save_image_and_nobg(self, pil_img: PILImage.Image, out_path: str) -> tuple[str, str | None]:
        """이미지를 저장하고 배경 제거 버전도 생성"""
        # 원본 결과 저장
        out_path = self._bump_suffix(out_path)
        pil_img.save(out_path)
        print(f"saved -> {out_path}")
        
        nobg_saved = None
        
        # rembg가 있을 때만 배경제거
        if _REMBG_AVAILABLE:
            buf = io.BytesIO()
            pil_img.save(buf, format="PNG")
            buf.seek(0)
            
            nobg_bytes = rembg_remove(buf.getvalue())
            nobg_img = PILImage.open(io.BytesIO(nobg_bytes)).convert("RGBA")
            
            root, _ = os.path.splitext(out_path)
            nobg_path = f"{root}_nobg.png"
            nobg_path = self._bump_suffix(nobg_path)
            nobg_img.save(nobg_path)
            print(f"saved -> {nobg_path}")
            nobg_saved = nobg_path
        else:
            print("NOTE: rembg not installed. Skipped background removal.")
        
        return out_path, nobg_saved
    
    async def generate_outfit(
        self,
        garment_image_bytes: bytes,
        out_size: tuple = (1024, 1024),
        aspect_ratio: str = "1:1"
    ) -> tuple[str | None, str | None]:
        """
        캐릭터에 옷을 입힌 이미지 생성
        
        Args:
            garment_image_bytes: 의상 이미지 바이트
            out_size: 출력 이미지 크기
            aspect_ratio: 출력 종횡비
            
        Returns:
            (원본 이미지 경로, 배경 제거 이미지 경로)
            
        Note:
            캐릭터 이미지는 temp/my_character.png 파일을 사용합니다.
        """
        # 고정된 캐릭터 이미지 파일 읽기
        if not os.path.exists(self.character_image_path):
            raise FileNotFoundError(f"캐릭터 이미지 파일을 찾을 수 없습니다: {self.character_image_path}")
        
        # 이미지를 PIL Image로 변환 후 PNG 바이트로 변환
        char_img = PILImage.open(self.character_image_path).convert("RGBA")
        garment_img = PILImage.open(io.BytesIO(garment_image_bytes)).convert("RGBA")
        
        buf_char = io.BytesIO()
        buf_garment = io.BytesIO()
        char_img.save(buf_char, format="PNG")
        garment_img.save(buf_garment, format="PNG")
        
        bytes_char = buf_char.getvalue()
        bytes_garment = buf_garment.getvalue()
        
        # Gemini 입력 Part 생성
        image_char = types.Part.from_bytes(data=bytes_char, mime_type="image/png")
        image_garment = types.Part.from_bytes(data=bytes_garment, mime_type="image/png")
        
        # 프롬프트 설정
        system_prompt = (
            "You are a precise image editor. Preserve identity and line-art style strictly."
        )
        user_prompt = (
            "[ANCHOR] Keep face, line-art style, pose, body shape, and background exactly the same.\n"
            "[GARMENT] Identify if it contains TOP, BOTTOM, or BOTH.\n"
            "- If TOP only → replace only the top.\n"
            "- If BOTTOM only → replace only the bottom.\n"
            "- If both → replace both top and bottom naturally.\n"
            "Also create SHOES that stylistically match the outfit.\n"
            "Do not change pose, lighting, proportions, or background.\n"
            "Keep composition square (1:1)."
        )
        
        # 출력 설정
        config = types.GenerateContentConfig(
            response_modalities=["IMAGE"],
            image_config=types.ImageConfig(aspect_ratio=aspect_ratio),
        )
        
        # Gemini API 호출
        response = self.client.models.generate_content(
            model=self.model,
            contents=[
                system_prompt,
                "ANCHOR (keep identity/line-art):", image_char,
                "GARMENT (clothing reference):", image_garment,
                user_prompt
            ],
            config=config,
        )
        
        # 결과 저장
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        out_basename = f"{self.output_dir}/edited_{timestamp}"
        
        main_saved = None
        nobg_saved = None
        
        for i, part in enumerate(getattr(response, "parts", [])):
            if getattr(part, "inline_data", None) and getattr(part.inline_data, "data", None):
                raw = part.inline_data.data
                pil = PILImage.open(io.BytesIO(raw)).convert("RGBA")
                pil_resized = pil.resize(out_size, PILImage.LANCZOS)
                
                out_path = f"{out_basename}_{i}.png"
                main_saved, nobg_saved = self._save_image_and_nobg(pil_resized, out_path)
                break  # 첫 번째 이미지만 사용
        
        return main_saved, nobg_saved
