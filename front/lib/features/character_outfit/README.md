# Character Outfit Feature - Flutter 컴포넌트

캐릭터에 옷을 입힌 이미지를 생성하는 Flutter 컴포넌트입니다.

## 📁 디렉토리 구조

```
features/character_outfit/
├── data/
│   └── remote/
│       └── character_outfit_api_service.dart    # API 서비스
└── presentation/
    └── widgets/
        ├── index.dart                            # Export 파일
        ├── character_outfit_widget.dart          # 기본 위젯
        └── character_outfit_full_widget.dart     # 완전한 위젯
```

## 🚀 사용 방법

### 1. 완전한 위젯 사용 (추천)

모든 기능(이미지 선택, API 호출, 결과 표시)이 포함된 위젯입니다.

```dart
import 'package:your_app/features/character_outfit/presentation/widgets/index.dart';

// 페이지에서 사용
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('캐릭터 옷 입히기')),
      body: CharacterOutfitFullWidget(
        onGenerationComplete: (generatedImage) {
          // 생성 완료 시 콜백
          print('이미지 생성 완료!');
        },
      ),
    );
  }
}
```

### 2. 기본 위젯 사용 (커스텀)

자신만의 이미지 선택 로직을 구현하고 싶을 때 사용합니다.

```dart
import 'package:your_app/features/character_outfit/presentation/widgets/index.dart';

CharacterOutfitWidget(
  onSelectGarment: () async {
    // 커스텀 이미지 선택 로직
    final image = await myCustomImagePicker();
    return image;
  },
  onSuccess: (generatedImage) {
    // 성공 처리
    print('생성 완료!');
  },
  onError: (error) {
    // 에러 처리
    print('에러: $error');
  },
)
```

### 3. API 서비스만 사용

직접 API를 호출하고 싶을 때 사용합니다.

```dart
import 'package:your_app/features/character_outfit/data/remote/character_outfit_api_service.dart';
import 'dart:typed_data';

final apiService = CharacterOutfitApiService();

// 의상 이미지로 캐릭터 옷 입히기
try {
  final Uint8List garmentImage = ...; // 의상 이미지 바이트
  final Uint8List result = await apiService.generateCharacterOutfit(garmentImage);
  
  // 생성된 이미지 사용
  Image.memory(result);
} catch (e) {
  print('에러: $e');
}
```

## 📝 API 명세

### POST /ai/character-outfit/generate

**Request:**
- Content-Type: `multipart/form-data`
- Body: `file` (의상 이미지)

**Response:**
- Content-Type: `image/png`
- Body: PNG 이미지 바이너리 (배경 제거된 캐릭터)

## ⚙️ 설정

### API Endpoint 추가 확인

`lib/core/network/api_endpoints.dart` 파일에 다음이 추가되었는지 확인하세요:

```dart
// Character Outfit (캐릭터 옷 입히기)
static const String aiCharacterOutfitGenerate = '/character-outfit/generate';
```

### 필요한 패키지

이미 프로젝트에 포함되어 있어야 하는 패키지들:
- `dio` - HTTP 클라이언트
- `flutter_image_compress` - 이미지 압축
- `image_picker` - 이미지 선택

## 🎨 위젯 설명

### CharacterOutfitFullWidget

**특징:**
- ✅ 이미지 선택 UI 포함 (갤러리/카메라)
- ✅ API 호출 자동 처리
- ✅ 로딩 상태 표시
- ✅ 에러 처리 포함
- ✅ 결과 이미지 표시

**Props:**
- `onGenerationComplete`: 생성 완료 콜백 (선택적)

### CharacterOutfitWidget

**특징:**
- 커스터마이징 가능한 기본 위젯
- 이미지 선택 로직을 직접 구현 가능

**Props:**
- `onSelectGarment`: 이미지 선택 콜백 (필수)
- `onSuccess`: 성공 콜백 (선택적)
- `onError`: 에러 콜백 (선택적)

## 🔧 커스터마이징 예시

### 다이얼로그로 표시

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: Container(
      padding: EdgeInsets.all(16),
      child: CharacterOutfitFullWidget(),
    ),
  ),
);
```

### 바텀 시트로 표시

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => Container(
    height: MediaQuery.of(context).size.height * 0.9,
    child: CharacterOutfitFullWidget(),
  ),
);
```

## 📌 주의사항

1. **백엔드 서버 실행 필요**
   - `temp/my_character.png` 파일이 백엔드에 존재해야 합니다.
   - `GOOGLE_API_KEY` 환경변수가 설정되어 있어야 합니다.

2. **처리 시간**
   - 이미지 생성에 약 30초 소요됩니다.
   - 사용자에게 로딩 메시지를 표시합니다.

3. **이미지 크기**
   - 업로드 전 자동으로 압축됩니다 (최대 1024px, 품질 90%).
   - 최대 파일 크기: 10MB

## 🐛 디버깅

### 로그 확인

위젯 사용 시 다음과 같은 로그가 출력됩니다:

```
👗 [캐릭터 옷 입히기] 원본 크기: XX KB
👗 [캐릭터 옷 입히기] 압축 후 크기: XX KB
👗 [캐릭터 옷 입히기] API 요청 시작
👗 [캐릭터 옷 입히기] API 응답 수신 완료
👗 [캐릭터 옷 입히기] 이미지 생성 완료
```

### Health Check

```dart
final apiService = CharacterOutfitApiService();
final health = await apiService.checkHealth();
print(health); // {"status": "healthy", "service": "character_outfit"}
```

## 📱 예제 전체 코드

```dart
import 'package:flutter/material.dart';
import 'package:your_app/features/character_outfit/presentation/widgets/index.dart';

class CharacterOutfitPage extends StatelessWidget {
  const CharacterOutfitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 옷 입히기'),
        backgroundColor: Colors.blue,
      ),
      body: CharacterOutfitFullWidget(
        onGenerationComplete: (generatedImage) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ 이미지 생성 완료!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
```
