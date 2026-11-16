part of '../../omni_core.dart';

class OperationResult<T> {
  final int statusCode;
  final int? bodyStatusCode;
  final bool success;
  final bool? hasNoInternetConnection;
  final T? data;
  final String? message;
  final String? messageAr;
  final String? messageUr;
  final ApiStatus? status;
  final Map<String, dynamic>? responseHeaders;

  OperationResult({
    required this.statusCode,
    this.bodyStatusCode,
    this.success = false,
    this.hasNoInternetConnection = false,
    this.data,
    this.status,
    this.message,
    this.messageAr,
    this.messageUr,
    this.responseHeaders,
  });
}

class ApiStatus {
  final int code;
  final String message;
  final String token;

  ApiStatus({required this.code, required this.message, required this.token});

  factory ApiStatus.fromJson(Map<String, dynamic> json) => ApiStatus(
    code: AppBaseModel.parseInt(json['code']) ?? 500,
    message: AppBaseModel.parseString(json['message']) ?? 'Unknown error',
    token: json['token'] as String? ?? '',
  );
}
