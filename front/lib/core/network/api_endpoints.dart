/// API 엔드포인트 관리
class ApiEndpoints {
  // ============================================
  // REST API (Spring Boot)
  // Base URL: http://localhost:8000/api
  // ============================================
  
  // Auth (인증)
  static const String userCreate = '/user/create'; // 익명 로그인
  
  // Weather (날씨)
  static const String tempForecast = '/temp/forecast';
  
  // 검색 관련
  static const String aiSearchTrending = '/search/trending'; // → http://localhost:8000/api/temp/forecast

  // ============================================
  // FastAPI (AI Server)
  // Base URL: http://localhost:8000/ai
  // ============================================
  
  // Products (의류 필터 검색)
  static const String aiProductsFilter = '/products'; // → http://localhost:8000/ai/products
  
  // Image Search (이미지 검색)
  static const String aiSearchImage = '/search/image'; // → http://localhost:8000/ai/search/image
  
  // Chatbot (챗봇)
  static const String aiChatbotChat = '/chatbot/chat'; // → http://localhost:8000/ai/chatbot/chat
  
  // Character Outfit (캐릭터 옷 입히기)
  static const String aiCharacterOutfitGenerate = '/character-outfit/generate'; // → http://localhost:8000/ai/character-outfit/generate
}

