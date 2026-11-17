part of '../../../omni_core.dart';

abstract class IApiService {
  /// Performs an HTTP GET request.
  ///
  /// [cacheType] selects the caching strategy for this single request. It is
  /// honored only by [DioApiService] (requires `enableCache: true` and a
  /// successfully initialized cache store). Other implementations may accept
  /// the parameter for interface conformance only.
  ///
  /// Setting [cacheType] on one call affects ONLY that call — the global
  /// interceptor default and any other in-flight or future requests are not
  /// changed.
  Future<OperationResult<T>> get<T>(
    String url, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
    RequestCacheTypes cacheType = RequestCacheTypes.refreshForceCache,
    bool waitingForImagesPrecaching = false,
  });

  Future<OperationResult<T>> post<T>(
    String url,
    dynamic data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    Map<String, String>? header,
    bool? isEncodedBody = false,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
    bool setResponseWithTheGenericType = false,
  });

  Future<OperationResult<T>> postWithFormDataSingleFile<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    required String formFieldKeyName,
    File? file,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<T>> postWithFormDataMultipleFiles<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    required String formFieldKeyName,
    List<File>? files,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<T>> postWithFormDataComplexFiles<T>(
    String url,
    Map<String, dynamic> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
    required String formFieldKeyName,
    List<String>? additionalFields,
    bool? usedForSnagsUpload,
  });

  Future<OperationResult<T>> put<T>(
    String url,
    dynamic data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    Map<String, String>? header,
    bool? isEncodedBody = false,
    bool checkOnTokenExpiration = true,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<T>> putWithFormDataSingleFile<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    required String formFieldKeyName,
    File? file,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<T>> putWithFormDataMultipleFiles<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    required String formFieldKeyName,
    List<File>? files,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<T>> patch<T>(
    String url,
    dynamic data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    Map<String, String>? header,
    bool? isEncodedBody = false,
    bool checkOnTokenExpiration = true,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<T>> patchWithFormDataMultipleFiles<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    required String formFieldKeyName,
    List<File>? files,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<T>> delete<T>(
    String url,
    Map data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    Map<String, String>? header,
    bool? isEncodedBody = false,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  Future<OperationResult<String>> downloadFile({
    required String url,
    required String savePath,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    void Function(int, int)? onReceiveProgress,
  });

  void cancelCurrentPageRequests({
    required String currentPageKeyForCancelTokens,
  });

  void cancelAllRequests();

  /// Clears all cached GET responses from the local cache store.
  ///
  /// Call this on logout to prevent cached responses for the previous user
  /// from being served to a new session on the same device.
  ///
  /// Default implementation is a no-op. Concrete clients with a cache store
  /// (e.g. [DioApiService]) override this to actually clear the store.
  Future<void> clearCache() async {}
}
