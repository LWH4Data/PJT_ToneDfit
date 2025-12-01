from google import genai
from google.genai import types
from PIL import Image as PILImage
import io
import os
import sys
import re  # 파일명 뒤 번호 자동 증가용



##############
# 상의만, 하의만, 상하의 다 가능. 신발은 어울리게끔 생성하게 해두었음(1:1비율, 1024 x 1024)
#
# GOOGLE_API_KEY EXPOSE로 넣어서 실행했음. 추후 변경되어야함 (export GOOGLE_API_KEY="API KEY")
#
# 아래 두개 필수로 install 해야만 함
# pip install google-genai
# pip install rembg onnxruntime
# 
# 실행방법
# python "현재 파일명" "캐릭터 이미지 파일명" "찍은 사진 파일명" --bg u2net
# ex) python generate.py my_character.png outfit.png --bg u2net
# 실행하면 30초 정도 소요됨
#
# 파일 저장시 --bg_n.png(생성된 이미지), --bg_n_nobg.png(배경 제거된 이미지)로 저장됨. n은 숫자, 변수로 1씩 증가하게끔 구현되어있음 
##############



# NOTE: 환경변수 GOOGLE_API_KEY or GEMINI_API_KEY 필요
client = genai.Client()

# NOTE: rembg 설치 여부를 런타임에 점검하고, 있으면 배경제거 기능 활성화
try:
    from rembg import remove as rembg_remove
    _REMBG_AVAILABLE = True
except Exception:
    _REMBG_AVAILABLE = False

# ← 추가: 이미 존재하면 뒤 번호를 1씩 증가시켜 가용 파일명을 반환
def _bump_suffix(path: str) -> str:
    root, ext = os.path.splitext(path)
    # root 끝의 _숫자 패턴을 찾아서 증가
    m = re.match(r"^(.*?)(?:_([0-9]+))$", root)
    if not os.path.exists(path):
        return path

    if m:
        base = m.group(1)
        n = int(m.group(2))
    else:
        base = root
        n = 0  # 처음엔 _0부터 시도

    while True:
        candidate = f"{base}_{n}{ext}"
        if not os.path.exists(candidate):
            return candidate
        n += 1

def _save_image_and_nobg(pil_img: PILImage.Image, out_path: str):
    # NOTE: 원본 결과 저장 (중복 시 뒤 숫자 증가)
    out_path = _bump_suffix(out_path)
    pil_img.save(out_path)
    print(f"saved -> {out_path}")

    nobg_saved = None

    # NOTE: rembg가 있을 때만 배경제거 이미지를 추가 저장
    if _REMBG_AVAILABLE:
        buf = io.BytesIO()
        pil_img.save(buf, format="PNG")
        buf.seek(0)

        # NOTE: rembg는 바이트 입력/출력을 사용하므로 바이트로 변환 후 처리
        nobg_bytes = rembg_remove(buf.getvalue())
        nobg_img = PILImage.open(io.BytesIO(nobg_bytes)).convert("RGBA")

        root, _ = os.path.splitext(out_path)
        nobg_path = f"{root}_nobg.png"
        nobg_path = _bump_suffix(nobg_path)  # ← 추가: nobg도 중복 검사
        nobg_img.save(nobg_path)
        print(f"saved -> {nobg_path}")
        nobg_saved = nobg_path
    else:
        print("NOTE: rembg not installed. Skipped background removal.")

    return out_path, nobg_saved

def edit_outfit(anchor_image_path: str,
                garment_image_path: str,
                out_basename: str = "edited",
                out_size: tuple = (1024, 1024),
                aspect_ratio: str = "1:1"):
    # NOTE: 모델 지정
    model = "gemini-2.5-flash-image"

    # NOTE: 이미지 A(앵커)와 B(의상)를 PNG 바이트로 변환
    with PILImage.open(anchor_image_path) as img_a, PILImage.open(garment_image_path) as img_b:
        img_a = img_a.convert("RGBA")   # JPG, JPEG, WEBP, etc → 문제없이 처리됨
        img_b = img_b.convert("RGBA")   # PNG 변환용 통일 처리

        buf_a = io.BytesIO(); img_a.save(buf_a, format="PNG")
        buf_b = io.BytesIO(); img_b.save(buf_b, format="PNG")
        bytes_a = buf_a.getvalue()
        bytes_b = buf_b.getvalue()

    # NOTE: Gemini 입력 Part 생성
    image_a = types.Part.from_bytes(data=bytes_a, mime_type="image/png")
    image_b = types.Part.from_bytes(data=bytes_b, mime_type="image/png")

    # NOTE: 시스템/사용자 프롬프트를 고정 템플릿으로 구성하여 수동 수정이 필요 없도록 함
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

    # NOTE: 출력 설정
    config = types.GenerateContentConfig(
        response_modalities=["IMAGE"],
        image_config=types.ImageConfig(aspect_ratio=aspect_ratio),
    )

    # NOTE: 멀티 이미지 입력(앵커 A + 의상 B)과 고정 템플릿 프롬프트 전달
    response = client.models.generate_content(
        model=model,
        contents=[
            system_prompt,
            "ANCHOR (keep identity/line-art):", image_a,
            "GARMENT (clothing reference):", image_b,
            user_prompt
        ],
        config=config,
    )

    # NOTE: 결과 저장 (SDK pydantic Image 대신 바이트를 직접 Pillow로 열어서 후처리)
    saved_paths = []
    for i, part in enumerate(getattr(response, "parts", [])):
        if getattr(part, "inline_data", None) and getattr(part.inline_data, "data", None):
            raw = part.inline_data.data
            pil = PILImage.open(io.BytesIO(raw)).convert("RGBA")
            pil_resized = pil.resize(out_size, PILImage.LANCZOS)

            # 기본 파일명 템플릿 만들기 (예: edited_0.png)
            out_path = f"{out_basename}_{i}.png"
            main_saved, nobg_saved = _save_image_and_nobg(pil_resized, out_path)
            saved_paths.append(main_saved)

    return saved_paths

if __name__ == "__main__":
    # NOTE: 프롬프트를 수정하지 않도록 파일 경로만 인자로 받는 형태
    # NOTE: 사용 예) python script.py my_character.png reference_jacket.png [OUT_BASENAME]
    if len(sys.argv) < 3:
        print("Usage: python script.py <ANCHOR_IMAGE> <GARMENT_IMAGE> [OUT_BASENAME]")
        sys.exit(1)

    anchor = sys.argv[1]
    garment = sys.argv[2]
    out_base = sys.argv[3] if len(sys.argv) > 3 else "edited"

    paths = edit_outfit(anchor, garment, out_basename=out_base)
    for p in paths:
        print(f"done -> {p}")

