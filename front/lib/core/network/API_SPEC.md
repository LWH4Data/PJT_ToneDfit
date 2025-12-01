# API 명세서

## FastAPI 엔드포인트

### 1. 상품 필터 검색

**Endpoint:** `GET /ai/products`

**Request Parameters:**
```
- apparentTemp (number, optional): 체감 온도
- query (string, optional): 사용자 검색어
- brand (string, optional): 브랜드명 (여러 개 가능, 쉼표로 구분)
- gender (string, optional): 성별 (예: "남성", "여성")
- largeCategory (string, optional): 대분류 (예: "아우터", "상의")
- smallCategory (string, optional): 소분류 (예: "트렌치/맥코트", "블라우스")
- minPrice (number, optional): 최소 가격
- maxPrice (number, optional): 최대 가격
- fabric (string, optional): 소재 (여러 개 가능, 쉼표로 구분)
- color (string, optional): 색상 (여러 개 가능, 쉼표로 구분)
- size (string, optional): 의류 사이즈 (여러 개 가능, 쉼표로 구분)
- page (number, default: 1): 응답 받을 데이터 뭉치 수
- pageSize (number, default: 20): 응답 받을 데이터 개수
```

**Request Example:**
```
GET /ai/products?gender=남성&largeCategory=아우터&smallCategory=트렌치/맥코트&minPrice=100000&maxPrice=500000&color=블랙&page=1&pageSize=20
```

**Response:**
```json
{
  "total": 2,
  "page": 1,
  "size": 20,
  "products": [
    {
      "productId": "29cm-2981331",
      "productUrl": "https://www.29cm.co.kr/products//2981331",
      "brand": "아웃스탠딩",
      "gender": "남성",
      "largeCategory": "하의",
      "smallCategory": "코튼 팬츠",
      "name": "BACK SATIN FATIGUE PANTS (ORIGINAL FIT)_WASHED OLIVE",
      "originalPrice": 93600,
      "colors": ["올리브"],
      "representativeImageUrl": "https://umeico.cafe24.com/product/OS25FW/main_02.jpg"
    },
    {
      "productId": "29cm-2809396",
      "productUrl": "https://www.29cm.co.kr/products//2809396",
      "brand": "플로움",
      "gender": "여성",
      "largeCategory": "원피스",
      "smallCategory": "미니 원피스",
      "name": "Velour Ribbon Dress - Mini",
      "originalPrice": 299280,
      "colors": ["블랙"],
      "representativeImageUrl": "https://img.29cm.co.kr/item/202409/11ef6b24632c0b16856a87fbdeda9c27.jpg"
    }
  ]
}
```

**Response Fields:**
- `total` (number): 전체 상품 개수
- `page` (number): 현재 페이지
- `size` (number): 페이지당 상품 개수
- `products` (array): 상품 목록
  - `productId` (string): 상품 ID
  - `productUrl` (string): 상품 URL
  - `brand` (string): 브랜드명
  - `gender` (string): 성별
  - `largeCategory` (string): 대분류
  - `smallCategory` (string): 소분류
  - `name` (string): 상품명
  - `originalPrice` (number): 원가
  - `colors` (array): 색상 목록
  - `representativeImageUrl` (string): 대표 이미지 URL

---

## Flutter 사용법

### 기본 필터 검색

```dart
final apiService = ClothApiService();

final response = await apiService.filterProducts(
  gender: '남성',
  largeCategory: '아우터',
  smallCategory: '트렌치/맥코트',
  page: 1,
  pageSize: 20,
);

print('총 ${response.total}개 중 ${response.products.length}개 표시');
```

### 고급 필터 검색 (모든 파라미터)

```dart
final response = await apiService.filterProducts(
  apparentTemp: 15.5,
  query: '겨울 자켓',
  brands: ['버버리', '막스마라'],
  gender: '남성',
  largeCategory: '아우터',
  smallCategory: '트렌치/맥코트',
  minPrice: 100000,
  maxPrice: 500000,
  fabrics: ['울', '캐시미어'],
  colors: ['블랙', '네이비'],
  sizes: ['M', 'L'],
  page: 1,
  pageSize: 20,
);
```

### 페이지네이션

```dart
// 첫 페이지
final page1 = await apiService.filterProducts(
  gender: '남성',
  page: 1,
  pageSize: 20,
);

// 다음 페이지가 있는지 확인
if (page1.hasNextPage) {
  final page2 = await apiService.filterProducts(
    gender: '남성',
    page: 2,
    pageSize: 20,
  );
}

// 총 페이지 수
print('총 ${page1.totalPages}페이지');
```

### 에러 처리

```dart
try {
  final response = await apiService.filterProducts(
    gender: '남성',
    largeCategory: '아우터',
  );
  
  // 성공
  print('${response.products.length}개 상품 로드됨');
} on ApiException catch (e) {
  // API 에러
  print('에러: ${e.message}');
} catch (e) {
  // 기타 에러
  print('알 수 없는 에러: $e');
}
```

---

## REST API 엔드포인트

(TODO: Spring Boot REST API 엔드포인트 추가 예정)

