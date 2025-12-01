import 'package:dio/dio.dart';

/// API 예외 처리
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다.';
        break;
      case DioExceptionType.connectionError:
        message = '인터넷 연결을 확인해주세요.';
        break;
      case DioExceptionType.badCertificate:
        message = '인증서 오류가 발생했습니다.';
        break;
      case DioExceptionType.unknown:
      default:
        message = error.message ?? '알 수 없는 오류가 발생했습니다.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  static String _handleBadResponse(Response? response) {
    if (response == null) return '서버 응답이 없습니다.';

    // FastAPI 에러 응답 형식 처리
    if (response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      
      // FastAPI 기본 에러 형식: {"detail": "error message"}
      if (data.containsKey('detail')) {
        return data['detail'].toString();
      }
      
      // 커스텀 에러 형식: {"message": "error message"}
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
    }

    // Status code별 기본 메시지
    switch (response.statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '인증이 필요합니다.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다.';
      case 422:
        return '입력값이 올바르지 않습니다.';
      case 500:
        return '서버 오류가 발생했습니다.';
      case 502:
        return '게이트웨이 오류가 발생했습니다.';
      case 503:
        return '서비스를 사용할 수 없습니다.';
      default:
        return '오류가 발생했습니다. (Status: ${response.statusCode})';
    }
  }

  @override
  String toString() => message;
}

