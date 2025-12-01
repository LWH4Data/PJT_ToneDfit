# 환경 변수 설정

## 개발 환경에서 실행

### 1. 로컬 FastAPI 서버 사용

```bash
# 기본 설정 (localhost:8000)
flutter run

# 커스텀 API URL
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### 2. Android 에뮬레이터

Android 에뮬레이터에서는 `localhost` 대신 `10.0.2.2` 사용:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### 3. iOS 시뮬레이터

iOS 시뮬레이터에서는 `localhost` 사용 가능:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

### 4. 실제 디바이스

같은 네트워크의 개발 서버 IP 주소 사용:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8000
```

## 프로덕션 빌드

```bash
flutter build apk --dart-define=API_BASE_URL=https://api.yourapp.com
flutter build ios --dart-define=API_BASE_URL=https://api.yourapp.com
```

## VS Code 설정

`.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Development)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=API_BASE_URL=http://localhost:8000"
      ]
    },
    {
      "name": "Flutter (Android Emulator)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=API_BASE_URL=http://10.0.2.2:8000"
      ]
    },
    {
      "name": "Flutter (Production)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=API_BASE_URL=https://api.yourapp.com"
      ]
    }
  ]
}
```

## FastAPI CORS 설정

FastAPI 서버에서 CORS 설정 필요:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 개발: 모든 origin 허용
    # allow_origins=["https://yourapp.com"],  # 프로덕션: 특정 origin만
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## 환경별 설정 파일

### development.env
```
API_BASE_URL=http://localhost:8000
```

### production.env
```
API_BASE_URL=https://api.yourapp.com
```

## 주의사항

1. **localhost**: Android 에뮬레이터에서는 작동하지 않음
2. **10.0.2.2**: Android 에뮬레이터의 호스트 머신 주소
3. **실제 디바이스**: 같은 네트워크에 연결되어 있어야 함
4. **HTTPS**: 프로덕션에서는 HTTPS 사용 권장
5. **API 키**: 민감한 정보는 환경 변수로 관리

