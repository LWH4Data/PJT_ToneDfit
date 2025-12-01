import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

/// 챗봇 API 서비스
class ChatbotApiService {
  final AiDioClient _aiDioClient = AiDioClient();

  /// 챗봇 메시지 전송
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    double? apparentTemp,
  }) async {
    final body = <String, dynamic>{'message': message};
    if (apparentTemp != null) {
      body['apparent_temp'] = apparentTemp;
    }

    final response = await _aiDioClient.post(
      '/chatbot/chat',
      data: body,
    );

    return response.data as Map<String, dynamic>;
  }
}

