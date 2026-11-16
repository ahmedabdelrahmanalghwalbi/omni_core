part of '../../../../omni_core.dart';

abstract class ApiLogger {
  static void logRequest({
    required String method,
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? headers,
    String? tag,
  }) {
    PackageLogger.info(
      '🚀 [API REQUEST] $method $endpoint\n'
      '📝 Body: ${body ?? 'No Body'}\n'
      '🔑 Headers: ${headers ?? 'No Headers'}',
      tag: 'API_LOGGER',
    );
  }

  static void logResponse({
    required String endpoint,
    required int statusCode,
    dynamic response,
    Map<String, dynamic>? headers,
    String? tag,
  }) {
    PackageLogger.info(
      '✅ [API RESPONSE] $endpoint\n'
      '🔢 Status: $statusCode\n',
      // '📦 Response: $response\n',
      // '🔑 Headers: ${headers?.map ?? 'No Headers'}'
      tag: 'API_LOGGER',
    );
  }

  static void logError({
    required String endpoint,
    dynamic error,
    StackTrace? stackTrace,
    int? statusCode,
    String? tag,
  }) {
    PackageLogger.error(
      '❌ [API ERROR] $endpoint\n'
      '⚠️ Status: ${statusCode ?? 'Unknown'}\n'
      '🛑 Error: $error\n'
      '📜 StackTrace: ${stackTrace ?? 'No StackTrace'}',
      tag: 'API_LOGGER',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
