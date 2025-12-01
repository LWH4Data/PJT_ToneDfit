# Calendar API 명세서

## 개요
캘린더에 기록된 날씨 느낌과 사용자 메모를 바탕으로 적합한 의류 상품을 추천하는 API입니다.

---

## Base URL
```
http://<EC2_HOST>:8000
```

---

## 1. 캘린더 텍스트로 상품 검색

### Endpoint
```
POST /ai/calendar
```

### Description
사용자가 캘린더에 기록한 날씨 느낌(추움/더움)과 메모를 결합한 텍스트로 유사한 의류 상품을 검색합니다.

### Request

#### Headers
```
Content-Type: application/json
```

#### Request Body Parameters
| Field | Type | Required | Default | Constraints | Description |
|-------|------|----------|---------|-------------|-------------|
| text | string | ✅ Yes | - | min_length: 1 | 날씨 느낌 + 사용자 메모를 결합한 텍스트 |
| limit | integer | ❌ No | 10 | min: 1, max: 100 | 반환할 결과 수 |

#### Request Body Schema
```typescript
{
  text: string,      // Required: 캘린더 텍스트
  limit?: number     // Optional: 결과 수 (기본값: 10)
}
```

#### Request Examples
```json
{
  "text": "추움 오늘 회의가 있어서 정장을 입어야 해",
  "limit": 10
}
```

```json
{
  "text": "더움 편하게 입고 싶어",
  "limit": 5
}
```

### Response

#### Success Response (200 OK)

**Response Body Schema**
```typescript
{
  timestamp: string,           // ISO 8601 형식의 검색 시간
  total: number,              // 검색된 총 결과 수
  results: ProductResult[]    // 상품 결과 배열
}
```

**ProductResult Schema**
```typescript
{
  product_id: string,                    // 상품 고유 ID (필수)
  score: number,                         // 유사도 점수 0.0~1.0 (필수)
  product_url: string | null,           // 상품 페이지 URL
  name: string | null,                  // 상품명
  brand: string | null,                 // 브랜드명
  gender: string | null,                // 성별 (예: "남성", "여성", "공용")
  large_category: string | null,        // 대분류 (예: "상의", "하의", "아우터")
  small_category: string | null,        // 소분류 (예: "니트", "청바지")
  colors: string[] | null,              // 색상 목록
  fabrics: string[] | null,             // 소재 목록
  sizes: string[] | null,               // 사이즈 목록
  original_price: number | null,        // 원가 (원 단위)
  representative_image_url: string | null  // 대표 이미지 URL
}
```

#### Response Fields Detail
| Field | Type | Nullable | Description | Example |
|-------|------|----------|-------------|---------|
| timestamp | string | No | 검색 수행 시간 (ISO 8601 형식) | "2024-11-18T14:30:00+09:00" |
| total | integer | No | 검색된 총 결과 수 | 10 |
| results | array | No | 검색 결과 리스트 (ProductResult 배열) | [...] |

**ProductResult Fields**
| Field | Type | Nullable | Description | Example |
|-------|------|----------|-------------|---------|
| product_id | string | No | 상품 고유 ID | "P123456" |
| score | float | No | 유사도 점수 (높을수록 유사) | 0.95 |
| product_url | string | Yes | 상품 페이지 URL | "https://..." |
| name | string | Yes | 상품명 | "따뜻한 울 니트" |
| brand | string | Yes | 브랜드명 | "BrandName" |
| gender | string | Yes | 성별 구분 | "남성", "여성", "공용" |
| large_category | string | Yes | 대분류 카테고리 | "상의", "하의", "아우터" |
| small_category | string | Yes | 소분류 카테고리 | "니트", "청바지" |
| colors | array[string] | Yes | 색상 목록 | ["베이지", "블랙"] |
| fabrics | array[string] | Yes | 소재 목록 | ["울", "캐시미어"] |
| sizes | array[string] | Yes | 사이즈 목록 | ["S", "M", "L"] |
| original_price | integer | Yes | 원가 (원) | 89900 |
| representative_image_url | string | Yes | 대표 이미지 URL | "https://..." |

#### Response Example
```json
{
  "timestamp": "2024-11-18T14:30:00+09:00",
  "total": 10,
  "results": [
    {
      "product_id": "P123456",
      "score": 0.95,
      "product_url": "https://example.com/product/123456",
      "name": "따뜻한 울 니트",
      "brand": "BrandName",
      "gender": "남성",
      "large_category": "상의",
      "small_category": "니트",
      "colors": ["베이지", "블랙", "그레이"],
      "fabrics": ["울", "캐시미어"],
      "sizes": ["S", "M", "L", "XL"],
      "original_price": 89900,
      "representative_image_url": "https://example.com/images/product123456.jpg"
    },
    {
      "product_id": "P789012",
      "score": 0.92,
      "product_url": "https://example.com/product/789012",
      "name": "슬림핏 정장 재킷",
      "brand": "SuitBrand",
      "gender": "남성",
      "large_category": "아우터",
      "small_category": "재킷",
      "colors": ["네이비", "차콜"],
      "fabrics": ["폴리에스터", "울"],
      "sizes": ["90", "95", "100", "105"],
      "original_price": 159000,
      "representative_image_url": "https://example.com/images/product789012.jpg"
    }
  ]
}
```

#### Error Responses

**400 Bad Request - 빈 텍스트**
```json
{
  "detail": "Text cannot be empty"
}
```

**400 Bad Request - 잘못된 요청 형식**
```json
{
  "detail": [
    {
      "loc": ["body", "limit"],
      "msg": "ensure this value is greater than or equal to 1",
      "type": "value_error"
    }
  ]
}
```

**500 Internal Server Error**
```json
{
  "detail": "Failed to search by calendar text: <error message>"
}
```

**503 Service Unavailable - 인덱스 없음**
```json
{
  "detail": "Calendar search index is not available"
}
```

---

## 2. Health Check

### Endpoint
```
GET /ai/calendar/health
```

### Description
Calendar API 서비스의 상태를 확인합니다.

### Request
요청 파라미터 없음

### Response

#### Success Response (200 OK)
```json
{
  "status": "healthy",
  "index_exists": true,
  "service": "calendar_search"
}
```

```json
{
  "status": "index_not_found",
  "index_exists": false,
  "service": "calendar_search"
}
```

```json
{
  "status": "unhealthy",
  "error": "Connection timeout",
  "service": "calendar_search"
}
```

---

## 사용 예시

### cURL
```bash
# 추운 날씨 + 회의
curl -X POST "http://<EC2_HOST>:8000/ai/calendar" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "추움 오늘 회의가 있어서 정장을 입어야 해",
    "limit": 10
  }'

# 더운 날씨 + 캐주얼
curl -X POST "http://<EC2_HOST>:8000/ai/calendar" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "더움 편하게 입고 싶어",
    "limit": 5
  }'

# Health Check
curl -X GET "http://<EC2_HOST>:8000/ai/calendar/health"
```

### JavaScript (fetch)
```javascript
// Calendar 검색
const searchByCalendar = async (text, limit = 10) => {
  try {
    const response = await fetch('http://<EC2_HOST>:8000/ai/calendar', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text: text,
        limit: limit
      })
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Calendar search failed:', error);
    throw error;
  }
};

// 사용 예시
searchByCalendar("추움 오늘 회의가 있어서 정장을 입어야 해", 10)
  .then(data => {
    console.log(`총 ${data.total}개의 상품을 찾았습니다.`);
    data.results.forEach(product => {
      console.log(`- ${product.name} (${product.brand}): ${product.score}`);
    });
  });
```

### Dart (Flutter)

#### Model Classes
```dart
// 상품 결과 모델
class ProductResult {
  final String productId;
  final double score;
  final String? productUrl;
  final String? name;
  final String? brand;
  final String? gender;
  final String? largeCategory;
  final String? smallCategory;
  final List<String>? colors;
  final List<String>? fabrics;
  final List<String>? sizes;
  final int? originalPrice;
  final String? representativeImageUrl;

  ProductResult({
    required this.productId,
    required this.score,
    this.productUrl,
    this.name,
    this.brand,
    this.gender,
    this.largeCategory,
    this.smallCategory,
    this.colors,
    this.fabrics,
    this.sizes,
    this.originalPrice,
    this.representativeImageUrl,
  });

  factory ProductResult.fromJson(Map<String, dynamic> json) {
    return ProductResult(
      productId: json['product_id'] as String,
      score: (json['score'] as num).toDouble(),
      productUrl: json['product_url'] as String?,
      name: json['name'] as String?,
      brand: json['brand'] as String?,
      gender: json['gender'] as String?,
      largeCategory: json['large_category'] as String?,
      smallCategory: json['small_category'] as String?,
      colors: (json['colors'] as List<dynamic>?)?.cast<String>(),
      fabrics: (json['fabrics'] as List<dynamic>?)?.cast<String>(),
      sizes: (json['sizes'] as List<dynamic>?)?.cast<String>(),
      originalPrice: json['original_price'] as int?,
      representativeImageUrl: json['representative_image_url'] as String?,
    );
  }
}

// 캘린더 검색 응답 모델
class CalendarSearchResponse {
  final String timestamp;
  final int total;
  final List<ProductResult> results;

  CalendarSearchResponse({
    required this.timestamp,
    required this.total,
    required this.results,
  });

  factory CalendarSearchResponse.fromJson(Map<String, dynamic> json) {
    return CalendarSearchResponse(
      timestamp: json['timestamp'] as String,
      total: json['total'] as int,
      results: (json['results'] as List<dynamic>)
          .map((item) => ProductResult.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

#### Service Class
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CalendarSearchService {
  final String baseUrl = 'http://<EC2_HOST>:8000';
  
  // 캘린더 텍스트로 상품 검색
  Future<CalendarSearchResponse> searchByCalendar({
    required String text,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/ai/calendar');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'limit': limit,
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return CalendarSearchResponse.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception('잘못된 요청: ${error['detail']}');
      } else if (response.statusCode == 503) {
        throw Exception('서비스 일시 중단: 검색 인덱스를 사용할 수 없습니다');
      } else {
        throw Exception('검색 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('캘린더 검색 오류: $e');
    }
  }
  
  // Health Check
  Future<Map<String, dynamic>> healthCheck() async {
    final url = Uri.parse('$baseUrl/ai/calendar/health');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }
}
```

#### 사용 예시
```dart
void main() async {
  final service = CalendarSearchService();
  
  try {
    // 검색 실행
    final response = await service.searchByCalendar(
      text: '추움 오늘 회의가 있어서 정장을 입어야 해',
      limit: 10,
    );
    
    print('검색 시간: ${response.timestamp}');
    print('총 ${response.total}개의 상품 발견\n');
    
    // 결과 출력
    for (var product in response.results) {
      print('상품 ID: ${product.productId}');
      print('상품명: ${product.name ?? "정보 없음"}');
      print('브랜드: ${product.brand ?? "정보 없음"}');
      print('유사도: ${product.score.toStringAsFixed(2)}');
      print('가격: ${product.originalPrice != null ? "${product.originalPrice}원" : "정보 없음"}');
      print('색상: ${product.colors?.join(", ") ?? "정보 없음"}');
      print('---');
    }
  } catch (e) {
    print('에러 발생: $e');
  }
}
```

#### Widget 예시 (Flutter UI)
```dart
class CalendarSearchWidget extends StatefulWidget {
  @override
  _CalendarSearchWidgetState createState() => _CalendarSearchWidgetState();
}

class _CalendarSearchWidgetState extends State<CalendarSearchWidget> {
  final CalendarSearchService _service = CalendarSearchService();
  final TextEditingController _textController = TextEditingController();
  CalendarSearchResponse? _searchResponse;
  bool _isLoading = false;

  Future<void> _search() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('텍스트를 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _service.searchByCalendar(
        text: _textController.text,
        limit: 10,
      );
      setState(() {
        _searchResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: '예: 추움 오늘 회의가 있어서 정장을 입어야 해',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: _search,
            ),
          ),
        ),
        if (_isLoading) CircularProgressIndicator(),
        if (_searchResponse != null)
          Expanded(
            child: ListView.builder(
              itemCount: _searchResponse!.results.length,
              itemBuilder: (context, index) {
                final product = _searchResponse!.results[index];
                return ListTile(
                  leading: product.representativeImageUrl != null
                      ? Image.network(product.representativeImageUrl!)
                      : Icon(Icons.image),
                  title: Text(product.name ?? '상품명 없음'),
                  subtitle: Text('${product.brand ?? ''} - ${product.originalPrice ?? ''}원'),
                  trailing: Text('${(product.score * 100).toStringAsFixed(0)}%'),
                );
              },
            ),
          ),
      ],
    );
  }
}
```

---

## 🎯 프론트엔드 개발 가이드

### 필수 사항

#### 1. Request 파라미터
```typescript
// 필수 파라미터
text: string        // 반드시 포함, 빈 문자열 불가

// 선택 파라미터
limit?: number      // 생략 시 기본값 10, 범위: 1~100
```

#### 2. Response 처리
```typescript
// 응답 구조
{
  timestamp: string,    // 항상 존재
  total: number,        // 항상 존재, 0 이상
  results: []          // 항상 존재, 빈 배열 가능
}

// results 배열의 각 아이템
{
  product_id: string,   // 항상 존재 (필수)
  score: number,        // 항상 존재 (필수)
  // 아래는 모두 null 가능 - null 체크 필수!
  name: string | null,
  brand: string | null,
  colors: string[] | null,
  // ... 기타 필드
}
```

#### 3. Null 처리 예시
```typescript
// TypeScript
const productName = product.name ?? '상품명 없음';
const price = product.original_price?.toLocaleString() ?? '가격 정보 없음';
const colors = product.colors?.join(', ') ?? '색상 정보 없음';

// Dart/Flutter
final productName = product.name ?? '상품명 없음';
final price = product.originalPrice?.toString() ?? '가격 정보 없음';
final colors = product.colors?.join(', ') ?? '색상 정보 없음';
```

#### 4. 에러 처리
```typescript
try {
  const response = await fetch('/ai/calendar', {...});
  
  if (!response.ok) {
    if (response.status === 400) {
      // 잘못된 요청 (빈 텍스트, limit 범위 초과 등)
      console.error('요청 데이터를 확인해주세요');
    } else if (response.status === 503) {
      // 서비스 일시 중단
      console.error('잠시 후 다시 시도해주세요');
    } else {
      // 기타 에러
      console.error('검색 실패');
    }
  }
  
  const data = await response.json();
  // 성공 처리
} catch (error) {
  // 네트워크 에러 등
  console.error('요청 실패:', error);
}
```

### 주요 특징

1. **텍스트 기반 검색**: 날씨 느낌과 사용자 메모를 자연어로 입력
2. **AI 기반 추천**: CLIP 모델을 사용한 의미적 유사도 검색
3. **중복 제거**: 동일한 상품이 중복으로 반환되지 않음
4. **유사도 점수**: 각 상품의 유사도 점수(score) 제공 (0.0~1.0, 높을수록 유사)
5. **상세 정보**: 상품의 색상, 소재, 사이즈, 가격 등 포함
6. **정렬**: results는 score 기준 내림차순 정렬

---

## 참고 사항

### 텍스트 입력 가이드
- 날씨 느낌(추움/더움) + 사용자 메모를 하나의 텍스트로 결합
- 자연스러운 문장 형태로 입력 가능
- 예시:
  - ✅ "추움 오늘 회의가 있어서 정장을 입어야 해"
  - ✅ "더움 편하게 입고 싶어"
  - ✅ "추움 데이트가 있어서 멋있게 입고 싶어"
  - ✅ "더움 운동할 예정이라 활동적인 옷 필요"

### 응답 처리
- `score`가 높을수록 입력 텍스트와 더 유사한 상품
- `results`는 유사도 순으로 정렬되어 반환
- 일부 필드는 `null`일 수 있으므로 null 체크 필요

### Rate Limiting
- 현재 Rate Limiting 없음
- 추후 추가될 수 있음

### CORS
- 모든 Origin 허용 (`Access-Control-Allow-Origin: *`)
- 프로덕션 환경에서는 특정 도메인으로 제한 권장

---

## Swagger UI
대화형 API 문서는 다음 URL에서 확인 가능합니다:
```
http://<EC2_HOST>:8000/docs
```

---

## 문의 및 지원
- API 관련 문의: [담당자 연락처]
- 이슈 발생 시: [이슈 트래킹 시스템]

---

**Last Updated**: 2024-11-18  
**API Version**: 1.0.0
