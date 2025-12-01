#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Prepare CLIP embeddings OFFLINE and dump as files for later OpenSearch ingest.
- Model: laion/CLIP-ViT-H-14-laion2B-s32B-b79K (1024-dim)
- Optional background removal (rembg) with tight crop before CLIP

Outputs under --out-prefix:
  (optional) <prefix>.docs.json         # --emit-docs-json 사용 시
  <prefix>.bulk.ndjson                  # ★ append 모드로 계속 누적 (resume 지원)
  <prefix>.mapping.json                 # 없으면 생성 (혹은 --force-mapping)
"""
from __future__ import annotations
import os, io, json, argparse, hashlib
from typing import List, Dict, Any, Optional, Tuple

import requests
import numpy as np
from PIL import Image
from tqdm import tqdm

import torch
import torch.nn.functional as F
from transformers import CLIPModel, CLIPProcessor

# --- rembg (배경 제거) ---
try:
    from rembg import remove as rembg_remove
    REMBG_AVAILABLE = True
except Exception:
    REMBG_AVAILABLE = False


# ------------------------------
# Background removal + tight crop
# ------------------------------
def remove_bg_and_crop(image_bytes: bytes,
                       pad_ratio: float = 0.06,
                       bg_color: Tuple[int, int, int] = (255, 255, 255)) -> Image.Image:
    """
    1) rembg로 배경 제거 (RGBA)
    2) 알파 마스크 bbox로 타이트 크롭
    3) bg_color 위에 합성해 RGB 반환
    """
    rgba_bytes = rembg_remove(image_bytes)  # RGBA PNG bytes
    rgba = Image.open(io.BytesIO(rgba_bytes)).convert("RGBA")

    alpha = np.array(rgba.split()[-1])  # A channel
    ys, xs = np.where(alpha > 0)
    if len(xs) == 0 or len(ys) == 0:
        # 마스크가 비면 원본 RGB로 폴백
        return Image.open(io.BytesIO(image_bytes)).convert("RGB")

    x1, y1, x2, y2 = xs.min(), ys.min(), xs.max(), ys.max()

    h, w = alpha.shape
    pw = int((x2 - x1 + 1) * pad_ratio)
    ph = int((y2 - y1 + 1) * pad_ratio)
    x1 = max(0, x1 - pw); y1 = max(0, y1 - ph)
    x2 = min(w - 1, x2 + pw); y2 = min(h - 1, y2 + ph)

    rgba_crop = rgba.crop((x1, y1, x2 + 1, y2 + 1))
    bg = Image.new("RGB", rgba_crop.size, bg_color)
    bg.paste(rgba_crop, mask=rgba_crop.split()[-1])
    return bg


# ------------------------------
# Helpers
# ------------------------------
def l2_normalize(v: np.ndarray, eps: float = 1e-12) -> np.ndarray:
    n = np.linalg.norm(v, axis=-1, keepdims=True)
    return v / (n + eps)

def mean_pool(vecs: np.ndarray) -> np.ndarray:
    if vecs.size == 0:
        return vecs
    m = vecs.mean(axis=0, keepdims=True)
    return l2_normalize(m)[0]

def fetch_image_bytes(url: str, timeout: int = 20) -> Optional[bytes]:
    try:
        r = requests.get(url, stream=True, timeout=timeout)
        r.raise_for_status()
        return r.content
    except Exception:
        return None

def dedup_preserve_order(seq: List[str]) -> List[str]:
    seen = set(); out = []
    for s in seq:
        if s not in seen:
            seen.add(s); out.append(s)
    return out

def stable_id(product_id: Optional[str], product_url: Optional[str]) -> str:
    if product_id and str(product_id).strip():
        return str(product_id)
    if product_url:
        return hashlib.sha1(product_url.encode("utf-8")).hexdigest()
    return hashlib.sha1(os.urandom(16)).hexdigest()

def build_text_prompt(item: Dict[str, Any]) -> str:
    brand = item.get("brand")
    gender = item.get("gender")
    lc = item.get("large_category")
    sc = item.get("small_category")
    name = item.get("name")
    colors = ",".join(item.get("colors", [])[:6])
    fabrics = ",".join(item.get("fabrics", [])[:6])

    head_parts = [p for p in [brand, gender, lc, sc] if p]
    head = " ".join(head_parts)
    meta = []
    if name: meta.append(name)
    if colors: meta.append(f"색상:{colors}")
    if fabrics: meta.append(f"소재:{fabrics}")
    return f"{head}. " + ", ".join(meta)


# ------------------------------
# Resume 지원 유틸
# ------------------------------
def load_processed_ids_from_ndjson(nd_path: str) -> set:
    """
    기존 <prefix>.bulk.ndjson에서 이미 기록된 _id 집합 추출.
    라인 손상(마지막 불완전 라인 등) 시 해당 라인은 무시.
    """
    done = set()
    if not os.path.exists(nd_path):
        return done
    toggle_meta = True  # meta line -> doc line -> meta line ...
    with open(nd_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if toggle_meta:
                try:
                    meta = json.loads(line)
                    _id = (meta.get("index") or meta.get("create") or meta.get("update") or {}).get("_id")
                    if _id is not None:
                        done.add(str(_id))
                except Exception:
                    # 손상 라인 무시
                    pass
            toggle_meta = not toggle_meta
    return done

def atomic_append(fp, meta: dict, doc: dict):
    """
    meta / doc 두 줄을 쓰고 flush + fsync.
    """
    fp.write(json.dumps(meta, ensure_ascii=False) + "\n")
    fp.write(json.dumps(doc, ensure_ascii=False) + "\n")
    fp.flush()
    os.fsync(fp.fileno())


# ------------------------------
# CLIP Embedder
# ------------------------------
class CLIPEmbedder:
    def __init__(self, model_id: str, device: Optional[str] = None,
                 fp16: bool = True, local_files_only: bool = False):
        if device is None:
            device = "cuda" if torch.cuda.is_available() else "cpu"
        self.device = torch.device(device)
        self.model = CLIPModel.from_pretrained(model_id, local_files_only=local_files_only).to(self.device).eval()
        self.processor = CLIPProcessor.from_pretrained(model_id, local_files_only=local_files_only)
        self.use_fp16 = fp16 and (self.device.type == "cuda")
        self.dim = int(getattr(self.model.config, "projection_dim", 512))

    @torch.inference_mode()
    def embed_texts(self, texts: List[str], batch_size: int = 32) -> np.ndarray:
        out = []
        for i in range(0, len(texts), batch_size):
            inputs = self.processor(text=texts[i:i+batch_size], return_tensors="pt",
                                    padding=True, truncation=True).to(self.device)
            feats = self.model.get_text_features(**inputs)
            if self.use_fp16: feats = feats.half()
            feats = F.normalize(feats, dim=-1)
            out.append(feats.detach().cpu().float().numpy())
        return np.vstack(out) if out else np.zeros((0, self.dim), dtype=np.float32)

    @torch.inference_mode()
    def embed_images(self, images: List[Image.Image], batch_size: int = 16) -> np.ndarray:
        out = []
        for i in range(0, len(images), batch_size):
            batch = [im.convert("RGB") for im in images[i:i+batch_size]]
            inputs = self.processor(images=batch, return_tensors="pt").to(self.device)
            feats = self.model.get_image_features(**inputs)
            if self.use_fp16: feats = feats.half()
            feats = F.normalize(feats, dim=-1)
            out.append(feats.detach().cpu().float().numpy())
        return np.vstack(out) if out else np.zeros((0, self.dim), dtype=np.float32)


# ------------------------------
# Main
# ------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="in_json", required=True, help="Input products JSON (list[dict])")
    ap.add_argument("--out-prefix", type=str, default="data/processed/fashion_products", help="Output prefix for files")
    ap.add_argument("--index", type=str, default="fashion_products", help="Index name in OpenSearch")

    # 🔧 CLIP & batching
    ap.add_argument("--model-id", type=str, default="laion/CLIP-ViT-H-14-laion2B-s32B-b79K")
    ap.add_argument("--alpha", type=float, default=0.7, help="fused = alpha*image + (1-alpha)*text")
    ap.add_argument("--batch-size", type=int, default=8, help="Text embedding batch")
    ap.add_argument("--img-batch-size", type=int, default=8, help="Image embedding batch")
    ap.add_argument("--max-images", type=int, default=8, help="Per-product image cap")
    ap.add_argument("--store-nested-images", action="store_true", help="Also store per-image vectors")
    ap.add_argument("--local-only", action="store_true", help="Use HF cache only (offline)")

    # 🔧 Background removal
    ap.add_argument("--bg-remove", action="store_true", help="Enable background removal (rembg)")
    ap.add_argument("--pad-ratio", type=float, default=0.06, help="Tight crop padding ratio")
    ap.add_argument("--bg-color", type=str, default="255,255,255", help="RGB background after cutout, e.g. '255,255,255'")

    # 🔧 Output/Resume options
    ap.add_argument("--emit-docs-json", action="store_true", help="Also emit <prefix>.docs.json (bulk 리스트)")
    ap.add_argument("--force-mapping", action="store_true", help="Overwrite mapping.json even if it exists")
    ap.add_argument("--fresh", action="store_true", help="Start fresh: remove existing NDJSON/docs before run")

    args = ap.parse_args()

    # parse bg_color
    try:
        bg_color = tuple(int(x) for x in args.bg_color.split(","))
        if len(bg_color) != 3: raise ValueError
    except Exception:
        bg_color = (255, 255, 255)

    # load items
    with open(args.in_json, "r", encoding="utf-8") as f:
        items = json.load(f)
        if not isinstance(items, list):
            items = [items]

    if args.bg_remove and not REMBG_AVAILABLE:
        print("[WARN] --bg-remove 지정되었지만 rembg가 설치되지 않았습니다. 배경 제거 없이 진행합니다.")

    embedder = CLIPEmbedder(model_id=args.model_id, local_files_only=args.local_only)

    # paths
    out_prefix = args.out_prefix
    os.makedirs(os.path.dirname(out_prefix), exist_ok=True)
    docs_path = f"{out_prefix}.docs.json"
    mapping_path = f"{out_prefix}.mapping.json"
    nd_path = f"{out_prefix}.bulk.ndjson"

    # fresh start
    if args.fresh:
        for p in [docs_path, nd_path]:
            if os.path.exists(p):
                os.remove(p)
        print("[INFO] --fresh: 기존 NDJSON/docs 파일 삭제 완료")

    # mapping 생성 (없으면 or 강제)
    mapping = {
        "settings": {"index": {"knn": True}, "knn.algo_param.ef_search": 128},
        "mappings": {
            "properties": {
                "product_id": {"type": "keyword"},
                "product_url": {"type": "keyword"},
                "name": {"type": "text"},
                "brand": {"type": "keyword"},
                "gender": {"type": "keyword"},
                "large_category": {"type": "keyword"},
                "small_category": {"type": "keyword"},
                "colors": {"type": "keyword"},
                "fabrics": {"type": "keyword"},
                "sizes": {"type": "keyword"},
                "original_price": {"type": "integer"},
                "representative_image_url": {"type": "keyword"},
                "fused_vec": {
                    "type": "knn_vector", "dimension": embedder.dim,
                    "method": {"name": "hnsw", "space_type": "cosinesimil", "engine": "nmslib"}
                },
                "image_vec": {"type": "knn_vector", "dimension": embedder.dim},
                "text_vec": {"type": "knn_vector", "dimension": embedder.dim},
                "images": {
                    "type": "nested",
                    "properties": {
                        "url": {"type": "keyword"},
                        "img_vec": {"type": "knn_vector", "dimension": embedder.dim}
                    }
                }
            }
        }
    }
    if args.force_mapping or not os.path.exists(mapping_path):
        with open(mapping_path, "w", encoding="utf-8") as f:
            json.dump(mapping, f, ensure_ascii=False, indent=2)
        print(f"Wrote mapping: {mapping_path}")
    else:
        print(f"[INFO] mapping 존재: {mapping_path} (생성 생략)")

    # resume: 이미 처리된 id 수집 (기존 ndjson에서)
    processed_ids = load_processed_ids_from_ndjson(nd_path)
    if processed_ids:
        print(f"[INFO] 기존 NDJSON에서 {len(processed_ids)}건의 _id 감지 (재시작 모드)")
    else:
        print("[INFO] 기존 NDJSON 없음 또는 비어있음 (신규 모드)")

    # docs.json을 원하면 준비
    docs_buffer: List[Dict[str, Any]] = []
    docs_emit = args.emit_docs_json

    # NDJSON append 오픈
    nd_fp = open(nd_path, "a", encoding="utf-8")

    appended = 0
    skipped = 0

    for it in tqdm(items, desc="embed"):
        pid = stable_id(it.get("product_id"), it.get("product_url"))

        # 이미 기록된 id면 스킵
        if pid in processed_ids:
            skipped += 1
            continue

        # build image url list (rep first)
        urls = []
        rep = it.get("representative_image_url")
        if rep: urls.append(rep)
        urls.extend(it.get("image_urls", []))
        urls = dedup_preserve_order(urls)[:args.max_images]

        # fetch & preprocess images
        images: List[Image.Image] = []
        for u in urls:
            b = fetch_image_bytes(u)
            if b is None: 
                continue
            if args.bg_remove and REMBG_AVAILABLE:
                try:
                    im = remove_bg_and_crop(b, pad_ratio=args.pad_ratio, bg_color=bg_color)
                except Exception:
                    # fallback to original if rembg fails on this image
                    im = Image.open(io.BytesIO(b)).convert("RGB")
            else:
                im = Image.open(io.BytesIO(b)).convert("RGB")
            images.append(im)

        if not images:
            # 이미지가 전혀 없으면 스킵(로그만)
            continue

        # 임베딩
        img_vecs = embedder.embed_images(images, batch_size=args.img_batch_size)   # (n, D)
        image_vec = mean_pool(img_vecs)                                            # (D,)

        prompt = build_text_prompt(it)
        text_vec = embedder.embed_texts([prompt], batch_size=args.batch_size)[0]   # (D,)

        fused_vec = l2_normalize(args.alpha * image_vec + (1.0 - args.alpha) * text_vec)

        doc = {
            "product_id": pid,
            "product_url": it.get("product_url"),
            "name": it.get("name"),
            "brand": it.get("brand"),
            "gender": it.get("gender"),
            "large_category": it.get("large_category"),
            "small_category": it.get("small_category"),
            "colors": it.get("colors", []),
            "fabrics": it.get("fabrics", []),
            "sizes": it.get("sizes", []),
            "original_price": it.get("original_price"),
            "representative_image_url": it.get("representative_image_url"),
            "image_vec": image_vec.tolist(),
            "text_vec": text_vec.tolist(),
            "fused_vec": fused_vec.tolist(),
        }
        if args.store_nested_images:
            nested = [{"url": u, "img_vec": v.tolist()} for u, v in zip(urls, img_vecs)]
            doc["images"] = nested

        # NDJSON에 한 건씩 원자적으로 append
        meta = {"index": {"_index": args.index, "_id": pid}}
        atomic_append(nd_fp, meta, doc)
        appended += 1

        # 재시작 시 중복 방지
        processed_ids.add(pid)

        # (옵션) docs.json 버퍼에도 보관
        if docs_emit:
            docs_buffer.append(doc)

    # 파일 닫기
    nd_fp.close()

    # (옵션) docs.json 쓰기
    if docs_emit:
        with open(docs_path, "w", encoding="utf-8") as f:
            json.dump(docs_buffer, f, ensure_ascii=False)
        print(f"Wrote docs: {docs_path} (count={len(docs_buffer)})")

    print(f"[DONE] appended={appended}, skipped(existing)={skipped}, ndjson={nd_path}")


if __name__ == "__main__":
    main()
