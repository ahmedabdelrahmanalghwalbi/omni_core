part of '../../../../omni_core.dart';

class DioApiService implements IApiService {
  final Dio _dio;
  final IApiServiceHelpers _apiServiceHelper;
  final DioApiCancelTokenManagerService _cancelTokenManager;
  final int _connectionTimeout;
  final int _receiveTimeout;
  final int _sendTimeout;
  final bool _enableCache;
  CacheStore? _cacheStore;
  bool _cacheInitialized = false;

  DioApiService({
    required this._dio,
    required this._apiServiceHelper,
    required this._cancelTokenManager,
    required this._connectionTimeout,
    required this._receiveTimeout,
    required this._sendTimeout,
    this._enableCache = false,
  }) {
    // Configure default Dio options
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: _connectionTimeout),
      receiveTimeout: Duration(seconds: _receiveTimeout),
      sendTimeout: Duration(seconds: _sendTimeout),
      validateStatus: (status) => true,
      receiveDataWhenStatusError: true,
    );

    // Add logging interceptors only (no cache interceptor yet)
    _addLoggingInterceptors();

    // Initialize cache asynchronously
    if (_enableCache) {
      _initializeCacheStore();
    }
  }

  /// Add logging interceptors
  void _addLoggingInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          PackageLogger.info('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          PackageLogger.info(
            'Response: ${response.statusCode} : ${response.statusMessage} : ${response.realUri.toString()}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          PackageLogger.error('API Error: ${e.message}', error: e);
          return handler.next(e);
        },
      ),
    );
  }

  /// Initialize cache store and add interceptor once ready
  Future<void> _initializeCacheStore() async {
    try {
      final cachePath = await _resolveCachePath();
      if (cachePath != null && cachePath.isNotEmpty) {
        _cacheStore = HiveCacheStore(cachePath);

        // Add cache interceptor only after store is initialized
        _addCacheInterceptor();

        _cacheInitialized = true;
        PackageLogger.info('[Cache] Store initialized at: $cachePath');
      }
    } catch (ex, st) {
      PackageLogger.error(
        '[Cache] Store init failed',
        error: ex,
        stackTrace: st,
      );
    }
  }

  /// Add cache interceptor with proper configuration
  void _addCacheInterceptor() {
    try {
      final cacheOptions = CacheOptions(
        store: _cacheStore,
        policy: CachePolicy.refreshForceCache,
        hitCacheOnNetworkFailure: true,
        maxStale: const Duration(days: 365),
        priority: CachePriority.normal,
      );

      // Insert at position 0 so it runs BEFORE the logging interceptor
      _dio.interceptors.insert(0, DioCacheInterceptor(options: cacheOptions));
      PackageLogger.info('[Cache] Interceptor added at index 0');
    } catch (ex, st) {
      PackageLogger.error(
        '[Cache] Interceptor init failed',
        error: ex,
        stackTrace: st,
      );
      return;
    }
  }

  Future<String?> _resolveCachePath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory(path_package.join(dir.path, 'dio_cache'));
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      return cacheDir.path;
    } catch (ex, st) {
      PackageLogger.error(
        '[Cache] Path resolution failed',
        error: ex,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Build cache options for specific request
  CacheOptions _buildCacheOptions(RequestCacheTypes cacheType) => CacheOptions(
    store: _cacheStore,
    policy: _mapCacheType(cacheType),
    hitCacheOnNetworkFailure: _canFallBackToCache(cacheType),
    maxStale: const Duration(days: 365),
    priority: CachePriority.normal,
  );

  /// `refresh` and `noCache` promise network data only, so a network failure
  /// must surface as an error instead of silently resolving with a stale
  /// cached response.
  bool _canFallBackToCache(RequestCacheTypes type) {
    switch (type) {
      case RequestCacheTypes.refresh:
      case RequestCacheTypes.noCache:
        return false;

      case RequestCacheTypes.request:
      case RequestCacheTypes.forceCache:
      case RequestCacheTypes.refreshForceCache:
        return true;
    }
  }

  /// Map cache type
  CachePolicy _mapCacheType(RequestCacheTypes type) {
    switch (type) {
      case RequestCacheTypes.request:
        return CachePolicy.request;

      case RequestCacheTypes.forceCache:
        return CachePolicy.forceCache;

      // CachePolicy.refresh only stores responses that carry cache headers;
      // refreshForceCache always stores, matching the documented contract.
      // Reading the cache on failure is disabled by _canFallBackToCache.
      case RequestCacheTypes.refresh:
        return CachePolicy.refreshForceCache;

      case RequestCacheTypes.noCache:
        return CachePolicy.noCache;

      case RequestCacheTypes.refreshForceCache:
        return CachePolicy.refreshForceCache;
    }
  }

  /// Extracts all image URLs from the response body and caches them
  /// in parallel using flutter_cache_manager.
  Future<void> _prefetchImages(dynamic data) async {
    try {
      final urls = <String>[];
      _extractImageUrls(data, urls);

      final uniqueUrls = urls.toSet();
      if (uniqueUrls.isEmpty) return;

      PackageLogger.info(
        '[ImageCache] Prefetching ${uniqueUrls.length} image(s)',
      );

      await Future.wait(
        uniqueUrls.map(_cacheImageSafely),
        eagerError: false, // one failure must not cancel others
      );
    } catch (ex, st) {
      PackageLogger.error(
        '[ImageCache] Prefetch failed',
        error: ex,
        stackTrace: st,
      );
    }
  }

  /// Extracts all image URLs from the response body, wherever they appear
  /// (map values, list items — e.g. multi-photo fields — or a bare string).
  void _extractImageUrls(dynamic value, List<String> collector) {
    try {
      if (value is String) {
        if (_isImageUrl(value)) collector.add(value);
      } else if (value is Map) {
        for (final val in value.values) {
          _extractImageUrls(val, collector);
        }
      } else if (value is List) {
        for (final item in value) {
          _extractImageUrls(item, collector);
        }
      }
    } catch (ex, st) {
      PackageLogger.error(ex.toString(), error: ex, stackTrace: st);
    }
  }

  /// Build request options with cache configuration
  Options _buildRequestOptions({
    required Map<String, String> headers,
    required RequestCacheTypes cacheType,
  }) {
    // If cache is not initialized, return regular options without cache.
    // Warn when the caller explicitly requested `forceCache` (cache-only):
    // they expect no network call, so silently falling back to the network
    // would be misleading.
    if (!_enableCache || !_cacheInitialized || _cacheStore == null) {
      if (cacheType == RequestCacheTypes.forceCache) {
        PackageLogger.warning(
          '[Cache] forceCache requested but cache is not ready '
          '(enableCache=$_enableCache, initialized=$_cacheInitialized). '
          'Request will fall back to the network.',
        );
      }
      return Options(headers: headers);
    }

    // Build cache options for this request
    final cacheOptions = _buildCacheOptions(cacheType);
    final options = cacheOptions.toOptions();
    options.headers = headers;

    return options;
  }

  /// Check if the url is an image. The extension is matched on the URI path
  /// (case-insensitive) so URLs with query strings — e.g. signed URLs — are
  /// still recognized.
  bool _isImageUrl(String url) {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return false;
      }
      final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
      return path.endsWith('.png') ||
          path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.webp');
    } catch (ex, st) {
      PackageLogger.error(ex.toString(), error: ex, stackTrace: st);
      return false;
    }
  }

  /// Cache image safely
  Future<void> _cacheImageSafely(String url) async {
    try {
      await AppImageCacheManagerUtils.instance.downloadFile(url);
      PackageLogger.info('[ImageCache] Cached: $url');
    } catch (ex, st) {
      PackageLogger.error(
        '[ImageCache] Failed to cache: $url',
        error: ex,
        stackTrace: st,
      );
    }
  }

  @override
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
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );

    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );

      // Build request options with cache configuration
      final options = _buildRequestOptions(
        headers: headers,
        cacheType: cacheType,
      );

      final response = await _dio.get<dynamic>(
        url,
        options: options,
        cancelToken: cancelToken,
      );

      // Image prefetch is part of the caching feature — only run it when
      // caching is enabled, otherwise images would be cached even though the
      // caller opted out. Errors are isolated inside _prefetchImages.
      if (_enableCache) {
        if (waitingForImagesPrecaching) {
          await _prefetchImages(response.data);
        } else {
          unawaited(_prefetchImages(response.data));
        }
      }
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
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
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );

    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );

      Response response;
      if (setResponseWithTheGenericType) {
        // Generic type version
        response = await _dio.post<T>(
          url,
          data: isEncodedBody == true ? jsonEncode(data) : data,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
      } else {
        // Dynamic version
        response = await _dio.post<dynamic>(
          url,
          data: isEncodedBody == true ? jsonEncode(data) : data,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
      }

      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
  Future<OperationResult<T>> postWithFormDataSingleFile<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    File? file,
    required String formFieldKeyName,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
    void Function(int, int)? onSendProgress,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );

    final headers = await _apiServiceHelper.buildHeadersMethod(
      additionalHeaders: header,
      addToken: addToken,
      basicPassword: basicPassword,
      basicUsername: basicUsername,
      isBasicAuth: isBasicAuth,
      contentType: contentType,
      addSessionCookie: addSessionCookie,
      acceptanceType: acceptanceType,
    );
    final formData = FormData.fromMap(data);
    if (file != null) {
      formData.files.add(
        MapEntry(
          formFieldKeyName,
          await MultipartFile.fromFile(
            file.path,
            filename: path_package.basename(file.path),
          ),
        ),
      );
    }

    try {
      final response = await _dio.post<dynamic>(
        url,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
  Future<OperationResult<T>> postWithFormDataMultipleFiles<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    List<File>? files,
    required String formFieldKeyName,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
    void Function(int, int)? onSendProgress,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );

    final headers = await _apiServiceHelper.buildHeadersMethod(
      additionalHeaders: header,
      addToken: addToken,
      basicPassword: basicPassword,
      basicUsername: basicUsername,
      isBasicAuth: isBasicAuth,
      contentType: contentType,
      addSessionCookie: addSessionCookie,
      acceptanceType: acceptanceType,
    );
    final formData = FormData.fromMap(data);
    if (files?.isNotEmpty ?? false) {
      for (var file in files!) {
        formData.files.add(
          MapEntry(
            formFieldKeyName,
            await MultipartFile.fromFile(
              file.path,
              filename: path_package.basename(file.path),
            ),
          ),
        );
      }
    }

    try {
      final response = await _dio.post<dynamic>(
        url,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
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
    void Function(int, int)? onSendProgress,
    required String formFieldKeyName,
    List<String>? additionalFields,
    bool? usedForSnagsUpload,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );

    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );
      final formData = await _convertToFormDataWithMultipleFiles(
        data,
        formFieldKeyName: formFieldKeyName,
        additionalFields: additionalFields,
        usedForSnagsUpload: usedForSnagsUpload,
      );
      final response = await _dio.post<dynamic>(
        url,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  Future<FormData> _convertToFormDataWithMultipleFiles(
    Map<String, dynamic> data, {
    List<String>? additionalFields,
    required String formFieldKeyName,
    bool? usedForSnagsUpload,
  }) async {
    final formData = FormData();

    // ✅ DYNAMIC FIELD ADDITION - Replace hardcoded fields
    if (additionalFields != null && additionalFields.isNotEmpty) {
      for (final field in additionalFields) {
        if (data.containsKey(field)) {
          formData.fields.add(MapEntry(field, data[field].toString()));
        }
      }
    }

    // Handle the nested fields array
    if (data.containsKey(formFieldKeyName) && data[formFieldKeyName] is List) {
      final fields = data[formFieldKeyName] as List;
      for (int i = 0; i < fields.length; i++) {
        final field = fields[i];
        if (field is Map<String, dynamic>) {
          if (usedForSnagsUpload == true) {
            await _addSnagFieldToFormData(
              formFieldKeyName,
              formData,
              field,
              '$formFieldKeyName[$i]',
            );
          } else {
            await _addFieldToFormData(
              formFieldKeyName,
              formData,
              field,
              '$formFieldKeyName[$i]',
            );
          }
        }
      }
    }

    return formData;
  }

  Future<void> _addFieldToFormData(
    String formFieldKeyName,
    FormData formData,
    Map<String, dynamic> field,
    String fieldPrefix,
  ) async {
    final key = field['key']?.toString() ?? '';
    final name = field['name']?.toString() ?? '';
    final title = field['title']?.toString() ?? '';
    final value = field['value'];

    // Add key, name, and title
    formData.fields.add(MapEntry('$fieldPrefix[key]', key));
    formData.fields.add(MapEntry('$fieldPrefix[name]', name));
    formData.fields.add(MapEntry('$fieldPrefix[title]', title));

    if (value is File) {
      // Handle file upload
      final fileName = value.path.split('/').last;
      formData.files.add(
        MapEntry(
          '$fieldPrefix[value]',
          await MultipartFile.fromFile(value.path, filename: fileName),
        ),
      );
    } else if (value is Map) {
      // Structured values (e.g. dynamic dropdown selections, and the items of
      // a repeating group) are expanded with bracket notation so the backend
      // reconstructs them as objects instead of receiving Dart's map toString
      // output.
      await _addStructuredValueToFormData(
        formData,
        '$fieldPrefix[value]',
        value,
      );
    } else if (field.containsKey(formFieldKeyName) &&
        field[formFieldKeyName] is List) {
      // Handle nested fields array
      final nestedFields = field[formFieldKeyName] as List;
      for (int i = 0; i < nestedFields.length; i++) {
        final nestedField = nestedFields[i];
        if (nestedField is Map<String, dynamic>) {
          await _addFieldToFormData(
            formFieldKeyName,
            formData,
            nestedField,
            '$fieldPrefix[$formFieldKeyName][$i]',
          );
        }
      }
    } else {
      // Normal values
      if (value != null) {
        formData.fields.add(MapEntry('$fieldPrefix[value]', value.toString()));
      }
    }
  }

  /// Expands a structured field value into bracket-notation form-data entries,
  /// at any depth, so nested objects and arrays reach the backend as such.
  ///
  /// Only reached for values that are already a map: a value that is itself a
  /// list keeps its existing serialization, so no field changes shape here.
  Future<void> _addStructuredValueToFormData(
    FormData formData,
    String valuePath,
    dynamic value,
  ) async {
    if (value == null) return;

    if (value is Map) {
      for (final entry in value.entries) {
        await _addStructuredValueToFormData(
          formData,
          '$valuePath[${entry.key}]',
          entry.value,
        );
      }
      return;
    }

    if (value is List) {
      for (int i = 0; i < value.length; i++) {
        await _addStructuredValueToFormData(
          formData,
          '$valuePath[$i]',
          value[i],
        );
      }
      return;
    }

    if (value is File) {
      formData.files.add(
        MapEntry(
          valuePath,
          await MultipartFile.fromFile(
            value.path,
            filename: value.path.split('/').last,
          ),
        ),
      );
      return;
    }

    formData.fields.add(MapEntry(valuePath, value.toString()));
  }

  Future<void> _addSnagFieldToFormData(
    String formFieldKeyName,
    FormData formData,
    Map<String, dynamic> field,
    String fieldPrefix,
  ) async {
    for (final entry in field.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == 'files' && value is List) {
        for (int j = 0; j < value.length; j++) {
          final file = value[j];

          if (file is File) {
            final fileName = file.path.split('/').last;

            formData.files.add(
              MapEntry(
                '$fieldPrefix[$key][]',
                await MultipartFile.fromFile(file.path, filename: fileName),
              ),
            );
          }
        }

        continue;
      }

      if (value is File) {
        final fileName = value.path.split('/').last;

        formData.files.add(
          MapEntry(
            '$fieldPrefix[$key]',
            await MultipartFile.fromFile(value.path, filename: fileName),
          ),
        );

        continue;
      }

      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          final nestedValue = value[i];

          if (nestedValue is Map<String, dynamic>) {
            await _addSnagFieldToFormData(
              formFieldKeyName,
              formData,
              nestedValue,
              '$fieldPrefix[$key][$i]',
            );
          }
        }
        continue;
      }

      if (value != null) {
        formData.fields.add(MapEntry('$fieldPrefix[$key]', value.toString()));
      }
    }
  }

  @override
  Future<OperationResult<T>> put<T>(
    String url,
    dynamic data, {
    required String dataKey,
    required String currentPageKeyForCancelTokens,
    Map<String, String>? header,
    bool checkOnTokenExpiration = true,
    bool? isEncodedBody = false,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );
    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );
      final response = await _dio.put<dynamic>(
        url,
        data: isEncodedBody == true ? jsonEncode(data) : data,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
  Future<OperationResult<T>> putWithFormDataSingleFile<T>(
    String url,
    Map<String, String> data, {
    required String dataKey,
    required String currentPageKeyForCancelTokens,
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
    void Function(int, int)? onSendProgress,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );

    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );
      final formData = FormData.fromMap(data);
      if (file != null) {
        formData.files.add(
          MapEntry(
            formFieldKeyName,
            await MultipartFile.fromFile(
              file.path,
              filename: path_package.basename(file.path),
            ),
          ),
        );
      }

      final response = await _dio.put<dynamic>(
        url,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
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
    void Function(int, int)? onSendProgress,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );
    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );
      final formData = FormData.fromMap(data);
      if (files?.isNotEmpty ?? false) {
        for (var file in files!) {
          formData.files.add(
            MapEntry(
              formFieldKeyName,
              await MultipartFile.fromFile(
                file.path,
                filename: path_package.basename(file.path),
              ),
            ),
          );
        }
      }

      final response = await _dio.put<dynamic>(
        url,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
  Future<OperationResult<T>> patch<T>(
    String url,
    dynamic data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    Map<String, String>? header,
    bool checkOnTokenExpiration = true,
    bool? isEncodedBody = false,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );
    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );
      final response = await _dio.patch<dynamic>(
        url,
        data: isEncodedBody == true ? jsonEncode(data) : data,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
  Future<OperationResult<T>> patchWithFormDataMultipleFiles<T>(
    String url,
    Map<String, String> data, {
    required String currentPageKeyForCancelTokens,
    required String dataKey,
    List<File>? files,
    required String formFieldKeyName,
    Map<String, String>? header,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
    void Function(int, int)? onSendProgress,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );

    final headers = await _apiServiceHelper.buildHeadersMethod(
      additionalHeaders: header,
      addToken: addToken,
      basicPassword: basicPassword,
      basicUsername: basicUsername,
      isBasicAuth: isBasicAuth,
      contentType: contentType,
      addSessionCookie: addSessionCookie,
      acceptanceType: acceptanceType,
    );
    final formData = FormData.fromMap(data);
    if (files?.isNotEmpty ?? false) {
      for (var file in files!) {
        formData.files.add(
          MapEntry(
            formFieldKeyName,
            await MultipartFile.fromFile(
              file.path,
              filename: path_package.basename(file.path),
            ),
          ),
        );
      }
    }

    try {
      final response = await _dio.patch<dynamic>(
        url,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
  Future<OperationResult<T>> delete<T>(
    String url,
    Map data, {
    required String dataKey,
    required String currentPageKeyForCancelTokens,
    Map<String, String>? header,
    bool? isEncodedBody = false,
    bool? addToken,
    bool? addSessionCookie,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  }) async {
    final cancelToken = _cancelTokenManager.createToken(
      pageKey: currentPageKeyForCancelTokens,
    );
    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        addSessionCookie: addSessionCookie,
        acceptanceType: acceptanceType,
      );
      final response = await _dio.delete<dynamic>(
        url,
        data: isEncodedBody == true ? jsonEncode(data) : data,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } on DioException catch (e, st) {
      return _handleDioException<T>(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  @override
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
  }) async {
    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        acceptanceType: RequestAcceptanceType.all,
        addSessionCookie: addSessionCookie,
      );

      // Create the directory if it doesn't exist
      final file = File(savePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Download the file
      final response = await _dio.download(
        url,
        savePath,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
      );

      return OperationResult<String>(
        data: savePath,
        statusCode: response.statusCode ?? 200,
        success: true,
        message: 'File downloaded successfully',
      );
    } on DioException catch (e, st) {
      return _handleDioException(error: e, endpoint: url, stackTrace: st);
    } catch (e, st) {
      return _apiServiceHelper.handleDIOApiCallsErrorsMethod<String>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  OperationResult<T> _handleResponse<T>({
    required String endpoint,
    required Response response,
    required String dataKey,
  }) {
    final int statusCode = response.statusCode ?? 500;
    final bool isSuccess = statusCode >= 200 && statusCode < 300;
    final data = response.data;

    // Handle unauthorized responses
    if (statusCode == 401 && _apiServiceHelper.unauthrizedCallback != null) {
      _apiServiceHelper.unauthrizedCallback!(data);
    }

    try {
      // Empty or unexpected data
      if (data == null || (data is String && data.isEmpty)) {
        return OperationResult<T>(
          data: null,
          statusCode: statusCode,
          success: isSuccess,
          message: isSuccess
              ? 'Empty response from server.'
              : 'Server returned an error with no data.',
          responseHeaders: response.headers.map,
        );
      }

      // Direct type match (most common and safe)
      if (data is T) {
        String? message;
        String? messageAr;
        String? messageUr;
        if (data is Map?) {
          message = data?['message']?.toString() ?? data?['error']?.toString();
          messageAr = data?['message_ar']?.toString();
          messageUr = data?['message_ur']?.toString();
        }
        return OperationResult<T>(
          data: data,
          message: message,
          messageAr: messageAr,
          messageUr: messageUr,
          statusCode: statusCode,
          success: isSuccess,
          responseHeaders: response.headers.map,
        );
      }

      // Handle List responses with proper type checking
      if (data is List) {
        return _handleListResponse<T>(
          data: data,
          statusCode: statusCode,
          isSuccess: isSuccess,
          responseHeaders: response.headers.map,
        );
      }

      // Handle Map responses
      if (data is Map) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic> safely
        final Map<String, dynamic> stringKeyedData = data.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        return _handleMapResponse<T>(
          data: stringKeyedData,
          statusCode: statusCode,
          isSuccess: isSuccess,
          dataKey: dataKey,
          responseHeaders: response.headers.map,
        );
      }

      //  Unexpected format
      ApiLogger.logError(
        endpoint: endpoint,
        error:
            'Unexpected response format. Expected $T but got ${data.runtimeType}',
        stackTrace: StackTrace.current,
        statusCode: statusCode,
      );
      return OperationResult<T>(
        data: null,
        statusCode: statusCode,
        success: false,
        message:
            'Something went wrong while processing the data. Please try again.',
        responseHeaders: response.headers.map,
      );
    } catch (e, stackTrace) {
      ApiLogger.logError(
        endpoint: endpoint,
        error: 'Error processing response: ${e.toString()}',
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      return OperationResult<T>(
        statusCode: statusCode,
        success: false,
        message:
            'Something went wrong while processing the data. Please try again.',
        responseHeaders: response.headers.map,
      );
    }
  }

  /// Helper method to handle List responses with proper type safety
  OperationResult<T> _handleListResponse<T>({
    required List<dynamic> data,
    required int statusCode,
    required bool isSuccess,
    required Map<String, dynamic> responseHeaders,
  }) {
    try {
      // Handle different List types based on generic type T
      if (T == List<Map<String, dynamic>>) {
        final convertedData = data.whereType<Map<String, dynamic>>().toList();
        return OperationResult<T>(
          data: convertedData as T,
          statusCode: statusCode,
          success: isSuccess,
          responseHeaders: responseHeaders,
        );
      } else if (T == List<dynamic>) {
        return OperationResult<T>(
          data: data as T,
          statusCode: statusCode,
          success: isSuccess,
          responseHeaders: responseHeaders,
        );
      } else if (T == List) {
        return OperationResult<T>(
          data: data as T,
          statusCode: statusCode,
          success: isSuccess,
          responseHeaders: responseHeaders,
        );
      } else {
        // For other List types, try conversion
        final convertedData = List<Map<String, dynamic>>.from(data);
        return OperationResult<T>(
          data: convertedData as T,
          statusCode: statusCode,
          success: isSuccess,
          responseHeaders: responseHeaders,
        );
      }
    } catch (e, stackTrace) {
      ApiLogger.logError(
        endpoint: 'List Response Handler',
        error: 'Error converting list data: ${e.toString()}',
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      return OperationResult<T>(
        data: null,
        statusCode: statusCode,
        success: false,
        message: 'Error processing list data',
        responseHeaders: responseHeaders,
      );
    }
  }

  /// Helper method to handle Map responses
  OperationResult<T> _handleMapResponse<T>({
    required Map<String, dynamic> data,
    required int statusCode,
    required bool isSuccess,
    required String dataKey,
    required Map<String, dynamic> responseHeaders,
  }) {
    try {
      final message = data['message']?.toString() ?? data['error']?.toString();
      final messageAr = data['message_ar']?.toString();
      final messageUr = data['message_ur']?.toString();

      // Extract data based on dataKey if provided
      dynamic resultData = data;
      if (dataKey.isNotEmpty && data.containsKey(dataKey)) {
        resultData = data[dataKey];
      }

      // If the extracted data matches the expected type T
      if (resultData is T) {
        return OperationResult<T>(
          data: resultData,
          message: message,
          messageAr: messageAr,
          messageUr: messageUr,
          statusCode: statusCode,
          success: isSuccess,
          responseHeaders: responseHeaders,
        );
      }

      // If we need to convert to a specific model
      return OperationResult<T>(
        data: resultData is T ? resultData : null,
        message: message,
        messageAr: messageAr,
        messageUr: messageUr,
        statusCode: statusCode,
        success: isSuccess,
        responseHeaders: responseHeaders,
      );
    } catch (e, stackTrace) {
      ApiLogger.logError(
        endpoint: 'Map Response Handler',
        error: 'Error processing map response: ${e.toString()}',
        stackTrace: stackTrace,
        statusCode: statusCode,
      );

      return OperationResult<T>(
        data: null,
        statusCode: statusCode,
        success: false,
        message: 'Error processing response data',
        responseHeaders: responseHeaders,
      );
    }
  }

  /// Handles all Dio exceptions professionally
  Future<OperationResult<T>> _handleDioException<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  }) async {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return _apiServiceHelper.handleDIOConnectionError<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      case DioExceptionType.connectionTimeout:
        return _apiServiceHelper.handleDIOConnectionTimeout<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      case DioExceptionType.sendTimeout:
        return _apiServiceHelper.handleDIOSendTimeout<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      case DioExceptionType.receiveTimeout:
        return _apiServiceHelper.handleDIOReceiveTimeout<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badCertificate:
        return _apiServiceHelper.handleDIOBadCertificate<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badResponse:
        return await _apiServiceHelper.handleDIOBadResponse<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      case DioExceptionType.cancel:
        return _apiServiceHelper.handleDIOCancelledRequest<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      case DioExceptionType.unknown:
        return _apiServiceHelper.handleDIOUnknownError<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );

      default:
        return _apiServiceHelper.handleDIOUnknownError<T>(
          error: error,
          endpoint: endpoint,
          stackTrace: stackTrace,
        );
    }
  }

  @override
  void cancelCurrentPageRequests({
    required String currentPageKeyForCancelTokens,
  }) {
    _cancelTokenManager.cancelRequests(pageKey: currentPageKeyForCancelTokens);
  }

  @override
  void cancelAllRequests() {
    _cancelTokenManager.cancelAll();
  }

  @override
  Future<void> clearCache() async {
    if (_cacheStore == null) return;
    try {
      await _cacheStore!.clean();
      PackageLogger.info('[Cache] Store cleared');
    } catch (ex, st) {
      PackageLogger.error('[Cache] Clear failed', error: ex, stackTrace: st);
    }
  }
}
