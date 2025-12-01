# Network Layer

FastAPI와 REST API 연동을 위한 Dio 클라이언트 및 API 서비스

## 📁 구조

```
lib/core/network/
├── dio_client.dart          # Dio 클라이언트 싱글톤
├── dio_interceptors.dart    # 로깅, 인증, 에러 처리 인터셉터
├── api_endpoints.dart       # API 엔드포인트 관리
├── api_exception.dart       # API 예외 처리
├── api_response.dart        # API 응답 래퍼
└── index.dart              # Barrel export
```

## 🚀 사용법

### 1. 기본 설정

**Base URL 변경** (`dio_client.dart`):
```dart
static String get baseUrl {
  if (kDebugMode) {
    return 'http://localhost:8000'; // 개발 환경
  } else {
    return 'https://your-api.com'; // 프로덕션
  }
}
```

### 2. API 서비스 생성

```dart
class MyApiService {
  final DioClient _dioClient = DioClient();

  Future<List<MyData>> getData() async {
    try {
      final response = await _dioClient.get('/api/data');
      return (response.data as List)
          .map((json) => MyData.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
```

### 3. API 호출 예시

```dart
final apiService = ClothApiService();

// 상품 조회
try {
  final products = await apiService.getProducts(page: 1, limit: 20);
  print('Products: ${products.length}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}

// 검색
try {
  final results = await apiService.searchProducts(
    query: '티셔츠',
    minPrice: 10000,
    maxPrice: 50000,
  );
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### 4. 인증 토큰 저장

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// 토큰 저장
await storage.write(key: 'access_token', value: 'your_token');
await storage.write(key: 'refresh_token', value: 'your_refresh_token');

// 이후 모든 요청에 자동으로 Authorization 헤더 추가됨
```

### 5. 요청 취소

```dart
final cancelToken = _dioClient.createCancelToken();

try {
  final response = await _dioClient.get(
    '/api/data',
    cancelToken: cancelToken,
  );
} catch (e) {
  // 취소 처리
}

// 나중에 취소
cancelToken.cancel('Cancelled by user');
```

## 🔧 커스터마이징

### 타임아웃 변경

`dio_client.dart`의 `_baseOptions`:
```dart
connectTimeout: const Duration(seconds: 30),
receiveTimeout: const Duration(seconds: 30),
```

### 커스텀 헤더 추가

```dart
final response = await _dioClient.get(
  '/api/data',
  options: Options(
    headers: {'Custom-Header': 'value'},
  ),
);
```

### 에러 메시지 커스터마이징

`dio_interceptors.dart`의 `ErrorInterceptor` 수정

## 📝 API 응답 형식

### FastAPI 표준 응답

```json
{
  "data": [...],
  "message": "Success",
  "status_code": 200
}
```

### 에러 응답

```json
{
  "detail": "Error message"
}
```

## 🔐 인증

AuthInterceptor가 자동으로 처리:
- 모든 요청에 `Authorization: Bearer {token}` 헤더 추가
- 401 에러 시 토큰 갱신 시도 (TODO: 구현 필요)

## 📌 주의사항

1. **Base URL**: 개발/프로덕션 환경에 맞게 설정
2. **토큰 갱신**: `AuthInterceptor`에서 토큰 갱신 로직 구현 필요
3. **에러 처리**: 모든 API 호출은 try-catch로 감싸기
4. **타입 안전성**: 응답 데이터를 적절한 모델로 변환

