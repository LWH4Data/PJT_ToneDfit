import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 로깅 인터셉터
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ [REQUEST] ${options.method} ${options.uri}');
      print('│ Headers: ${options.headers}');
      if (options.data != null) {
        print('│ Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        print('│ Query Parameters: ${options.queryParameters}');
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
      print('│ Data: ${response.data}');
      print('└─────────────────────────────────────────────────────────────');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ [ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}');
      print('│ Type: ${err.type}');
      print('│ Message: ${err.message}');
      if (err.response != null) {
        print('│ Status Code: ${err.response?.statusCode}');
        print('│ Data: ${err.response?.data}');
      }
      print('└─────────────────────────────────────────────────────────────');
    }
    super.onError(err, handler);
  }
}

/// 인증 인터셉터 (토큰 자동 추가)
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 토큰이 필요한 요청에 자동으로 추가
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러 시 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      try {
        // 토큰 갱신 로직
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          // TODO: 토큰 갱신 API 호출
          // final newToken = await refreshAccessToken(refreshToken);
          // await _storage.write(key: 'access_token', value: newToken);
          // 
          // // 실패했던 요청 재시도
          // final opts = err.requestOptions;
          // opts.headers['Authorization'] = 'Bearer $newToken';
          // final response = await Dio().fetch(opts);
          // return handler.resolve(response);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Token refresh failed: $e');
        }
      }
    }
    super.onError(err, handler);
  }
}

/// 에러 처리 인터셉터
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCode(err.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = '요청이 취소되었습니다.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = '인터넷 연결을 확인해주세요.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = '인증서 오류가 발생했습니다.';
        break;
      case DioExceptionType.unknown:
      default:
        errorMessage = '알 수 없는 오류가 발생했습니다.';
        break;
    }

    // 에러 메시지를 DioException에 추가
    final newErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      message: errorMessage,
    );

    super.onError(newErr, handler);
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '인증이 필요합니다.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 리소스를 찾을 수 없습니다.';
      case 500:
        return '서버 오류가 발생했습니다.';
      case 502:
        return '게이트웨이 오류가 발생했습니다.';
      case 503:
        return '서비스를 사용할 수 없습니다.';
      default:
        return '오류가 발생했습니다. (Status: $statusCode)';
    }
  }
}

