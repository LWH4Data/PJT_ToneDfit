"""
OpenSearch에 이미지 데이터를 인덱싱하는 예제 스크립트

사용법:
1. 이미지 파일들을 준비
2. 상품 정보 CSV 또는 JSON 파일 준비
3. 이 스크립트를 수정하여 데이터 로드 및 인덱싱 실행
"""

import os
import json
from pathlib import Path
from opensearchpy import OpenSearch
from PIL import Image
import sys

# 상위 디렉토리를 path에 추가하여 app 모듈 import 가능하게 함
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.libraries.image_embedding_model import get_image_embedding_model
from app.core.config import settings


def get_opensearch_client():
    """OpenSearch 클라이언트 생성"""
    return OpenSearch(
        hosts=[{
            'host': settings.opensearch_host,
            'port': settings.opensearch_port
        }],
        http_compress=True,
        use_ssl=False,
        verify_certs=False,
        ssl_assert_hostname=False,
        ssl_show_warn=False,
    )


def create_index_if_not_exists(client, index_name):
    """인덱스가 없으면 생성"""
    if not client.indices.exists(index=index_name):
        # 매핑 파일 읽기
        mapping_file = Path(__file__).parent / "opensearch_index_mapping.json"
        with open(mapping_file, 'r', encoding='utf-8') as f:
            mapping = json.load(f)
        
        # 인덱스 생성
        client.indices.create(index=index_name, body=mapping)
        print(f"Index '{index_name}' created successfully")
    else:
        print(f"Index '{index_name}' already exists")


def index_image(client, embedding_model, index_name, product_id, image_path, product_data):
    """
    단일 이미지를 인덱싱
    
    Args:
        client: OpenSearch 클라이언트
        embedding_model: 이미지 임베딩 모델
        index_name: 인덱스 이름
        product_id: 상품 ID
        image_path: 이미지 파일 경로
        product_data: 상품 정보 딕셔너리
    """
    try:
        # 이미지 읽기
        with open(image_path, 'rb') as f:
            image_bytes = f.read()
        
        # 임베딩 생성
        print(f"Embedding image for product {product_id}...")
        embedding = embedding_model.encode_image(image_bytes)
        
        # 데이터 준비
        document = {
            'product_id': product_id,
            'product_name': product_data.get('name', ''),
            'image_url': product_data.get('image_url', ''),
            'price': product_data.get('price', 0),
            'brand': product_data.get('brand', ''),
            'category': product_data.get('category', ''),
            'image_embedding': embedding
        }
        
        # OpenSearch에 인덱싱
        response = client.index(
            index=index_name,
            body=document,
            id=product_id,
            refresh=True
        )
        
        print(f"Product {product_id} indexed successfully")
        return response
        
    except Exception as e:
        print(f"Error indexing product {product_id}: {str(e)}")
        return None


def index_images_batch(client, embedding_model, index_name, products):
    """
    여러 이미지를 배치로 인덱싱
    
    Args:
        client: OpenSearch 클라이언트
        embedding_model: 이미지 임베딩 모델
        index_name: 인덱스 이름
        products: 상품 정보 리스트 [{'id': ..., 'image_path': ..., 'data': {...}}, ...]
    """
    from opensearchpy import helpers
    
    # 이미지 임베딩 생성
    print(f"Creating embeddings for {len(products)} images...")
    image_bytes_list = []
    valid_products = []
    
    for product in products:
        try:
            with open(product['image_path'], 'rb') as f:
                image_bytes_list.append(f.read())
                valid_products.append(product)
        except Exception as e:
            print(f"Error reading image {product['image_path']}: {str(e)}")
    
    if not valid_products:
        print("No valid images to process")
        return
    
    # 배치 임베딩 생성
    embeddings = embedding_model.encode_images_batch(image_bytes_list)
    
    # 벌크 인덱싱 준비
    actions = []
    for product, embedding in zip(valid_products, embeddings):
        action = {
            '_index': index_name,
            '_id': product['id'],
            '_source': {
                'product_id': product['id'],
                'product_name': product['data'].get('name', ''),
                'image_url': product['data'].get('image_url', ''),
                'price': product['data'].get('price', 0),
                'brand': product['data'].get('brand', ''),
                'category': product['data'].get('category', ''),
                'image_embedding': embedding
            }
        }
        actions.append(action)
    
    # 벌크 인덱싱 실행
    print(f"Bulk indexing {len(actions)} documents...")
    success, failed = helpers.bulk(client, actions, refresh=True)
    print(f"Successfully indexed: {success}, Failed: {len(failed)}")
    
    return success, failed


def main():
    """메인 실행 함수"""
    print("=== Image Indexing Script ===")
    
    # 클라이언트 및 모델 초기화
    print("Initializing OpenSearch client and embedding model...")
    client = get_opensearch_client()
    embedding_model = get_image_embedding_model()
    index_name = settings.image_index_name
    
    # 인덱스 생성
    create_index_if_not_exists(client, index_name)
    
    # 예제: 단일 이미지 인덱싱
    # index_image(
    #     client=client,
    #     embedding_model=embedding_model,
    #     index_name=index_name,
    #     product_id='P123456',
    #     image_path='path/to/image.jpg',
    #     product_data={
    #         'name': '화이트 티셔츠',
    #         'image_url': 'https://example.com/image.jpg',
    #         'price': 29900,
    #         'brand': 'BrandName',
    #         'category': '상의'
    #     }
    # )
    
    # 예제: 배치 인덱싱
    # products = [
    #     {
    #         'id': 'P123456',
    #         'image_path': 'path/to/image1.jpg',
    #         'data': {
    #             'name': '화이트 티셔츠',
    #             'image_url': 'https://example.com/image1.jpg',
    #             'price': 29900,
    #             'brand': 'BrandName',
    #             'category': '상의'
    #         }
    #     },
    #     {
    #         'id': 'P123457',
    #         'image_path': 'path/to/image2.jpg',
    #         'data': {
    #             'name': '블랙 청바지',
    #             'image_url': 'https://example.com/image2.jpg',
    #             'price': 59900,
    #             'brand': 'BrandName',
    #             'category': '하의'
    #         }
    #     }
    # ]
    # index_images_batch(client, embedding_model, index_name, products)
    
    print("TODO: 실제 데이터를 로드하고 인덱싱하는 코드를 작성하세요")
    print("위의 예제 코드를 참고하여 주석을 해제하고 수정하세요")


if __name__ == "__main__":
    main()
