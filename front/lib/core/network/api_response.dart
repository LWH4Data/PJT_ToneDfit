/// API 응답 래퍼 클래스
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  /// 성공 응답
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// 실패 응답
  factory ApiResponse.failure({
    required String message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  /// JSON에서 변환
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? true,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message']?.toString(),
      statusCode: json['statusCode'] as int?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'success': success,
      if (data != null) 'data': toJsonT(data as T),
      if (message != null) 'message': message,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }
}

