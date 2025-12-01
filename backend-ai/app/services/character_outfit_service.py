"""캐릭터 옷 입히기 서비스"""
from app.repositories.character_outfit_repository import CharacterOutfitRepository


class CharacterOutfitService:
    """캐릭터 옷 입히기 비즈니스 로직"""
    
    def __init__(self):
        """서비스 초기화"""
        self.repository = CharacterOutfitRepository()
    
    async def generate_character_outfit(
        self,
        garment_image_bytes: bytes
    ) -> str:
        """
        캐릭터에 옷을 입힌 이미지 생성
        
        Args:
            garment_image_bytes: 의상 이미지 바이트
            
        Returns:
            생성된 이미지 파일 경로 (배경 제거된 버전)
            
        Note:
            캐릭터 이미지는 my_character.png 파일을 사용합니다.
        """
        # 이미지 생성
        main_path, nobg_path = await self.repository.generate_outfit(
            garment_image_bytes=garment_image_bytes
        )
        
        if not nobg_path and not main_path:
            raise Exception("이미지 생성에 실패했습니다.")
        
        # 배경 제거 버전을 우선 반환, 없으면 원본 반환
        return nobg_path if nobg_path else main_path
