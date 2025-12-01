"""캐릭터 옷 입히기 API 엔드포인트"""
from functools import lru_cache
from fastapi import APIRouter, Depends, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
from app.services.character_outfit_service import CharacterOutfitService
from app.schemas.character_outfit_response import CharacterOutfitResponse

router = APIRouter()


@lru_cache(maxsize=1)
def get_character_outfit_service() -> CharacterOutfitService:
    """캐릭터 옷 입히기 서비스 인스턴스 반환"""
    return CharacterOutfitService()


@router.post("/generate")
async def generate_character_outfit(
    file: UploadFile = File(..., description="의상 이미지 파일"),
    service: CharacterOutfitService = Depends(get_character_outfit_service)
):
    """
    캐릭터에 옷을 입힌 이미지 생성
    
    - **file**: 입힐 의상 이미지 파일 (jpg, jpeg, png 등)
    
    Returns:
        생성된 PNG 이미지 파일 (배경 제거된 버전) 
    
    Note:
        캐릭터 이미지는 서버의 my_character.png 파일을 사용합니다.
    """
    # 의상 이미지 유효성 검사
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=400,
            detail="Invalid file type. Please upload an image file."
        )
    
    # 파일 크기 제한 (예: 10MB)
    max_file_size = 10 * 1024 * 1024  # 10MB
    
    garment_contents = await file.read()
    if len(garment_contents) > max_file_size:
        raise HTTPException(
            status_code=400,
            detail=f"File size exceeds maximum limit of {max_file_size // (1024*1024)}MB"
        )
    
    # 이미지 생성
    try:
        image_path = await service.generate_character_outfit(
            garment_image_bytes=garment_contents
        )
        
        # 생성된 이미지 파일을 직접 반환
        return FileResponse(
            path=image_path,
            media_type="image/png",
            filename="character_outfit.png"
        )
    except FileNotFoundError as e:
        raise HTTPException(
            status_code=404,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate character outfit: {str(e)}"
        )


@router.get("/health")
async def health_check(
    service: CharacterOutfitService = Depends(get_character_outfit_service)
):
    """캐릭터 옷 입히기 서비스 헬스 체크"""
    try:
        return {
            "status": "healthy",
            "service": "character_outfit",
            "gemini_model": service.repository.model
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "service": "character_outfit"
        }
