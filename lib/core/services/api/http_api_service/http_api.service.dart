part of '../../../../omni_core.dart';

class HttpApiService implements IApiService {
  final InternetConnectionService _internetConnectionService;
  final IApiServiceHelpers _apiServiceHelper;
  HttpApiService({
    required InternetConnectionService internetConnectionService,
    required IApiServiceHelpers apiServiceHelper,
  }) : _internetConnectionService = internetConnectionService,
       _apiServiceHelper = apiServiceHelper;

  @override
  Future<OperationResult<T>> get<T>(
    String url, {
    required String dataKey,
    required String currentPageKeyForCancelTokens,
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
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
    try {
      final headers = await _apiServiceHelper.buildHeadersMethod(
        additionalHeaders: header,
        addToken: addToken,
        basicPassword: basicPassword,
        basicUsername: basicUsername,
        isBasicAuth: isBasicAuth,
        contentType: contentType,
        acceptanceType: acceptanceType,
        addSessionCookie: addSessionCookie,
      );
      final response = await http.get(Uri.parse(url), headers: headers);
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    bool setResponseWithTheGenericType = false,
  }) async {
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: (isEncodedBody == true) ? jsonEncode(data) : data,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    required String dataKey,
    required String currentPageKeyForCancelTokens,
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
  }) async {
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(header ?? {});
    request.headers.addAll(headers);
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    if (file != null) {
      final mimeType = _getMimeType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          formFieldKeyName,
          file.path,
          contentType: mimeType,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    required String dataKey,
    required String currentPageKeyForCancelTokens,
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
  }) async {
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(header ?? {});
    request.headers.addAll(headers);
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    if (files?.isNotEmpty ?? false) {
      for (var file in files!) {
        final mimeType = _getMimeType(file.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            formFieldKeyName,
            file.path,
            contentType: mimeType,
          ),
        );
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    required String dataKey,
    required String currentPageKeyForCancelTokens,
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
    final bool? usedForSnagsUpload,
  }) async {
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(header ?? {});
    request.headers.addAll(headers);

    // ✅ DYNAMIC FIELD ADDITION - Replace hardcoded fields
    if (additionalFields != null && additionalFields.isNotEmpty) {
      for (final field in additionalFields) {
        if (data.containsKey(field)) {
          request.fields[field] = data[field].toString();
        }
      }
    }

    // Handle the nested fields array
    if (data.containsKey(formFieldKeyName) && data[formFieldKeyName] is List) {
      final fields = data[formFieldKeyName] as List;
      for (int i = 0; i < fields.length; i++) {
        final field = fields[i];
        if (field is Map<String, dynamic>) {
          _addFieldToRequest(
            formFieldKeyName,
            request,
            field,
            '$formFieldKeyName[$i]',
          );
        }
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  void _addFieldToRequest(
    String formFieldKeyName,
    http.MultipartRequest request,
    Map<String, dynamic> field,
    String fieldPrefix,
  ) {
    final key = field['key']?.toString() ?? '';
    final name = field['name']?.toString() ?? '';
    final title = field['title']?.toString() ?? '';
    final value = field['value'];

    // ✅ Always include key, name, and title
    request.fields['$fieldPrefix[key]'] = key;
    request.fields['$fieldPrefix[name]'] = name;
    request.fields['$fieldPrefix[title]'] = title;

    if (value is File) {
      // ✅ If file → attach as binary
      final mimeType = _getMimeType(value.path);
      request.files.add(
        http.MultipartFile.fromBytes(
          '$fieldPrefix[value]',
          value.readAsBytesSync(),
          filename: value.path.split('/').last,
          contentType: mimeType,
        ),
      );
    } else if (value is Map) {
      // Structured values (e.g. dynamic dropdown selections) are expanded
      // with bracket notation so the backend reconstructs them as objects
      // instead of receiving Dart's map toString output.
      for (final entry in value.entries) {
        if (entry.value != null) {
          request.fields['$fieldPrefix[value][${entry.key}]'] = entry.value
              .toString();
        }
      }
    } else if (field.containsKey(formFieldKeyName) &&
        field[formFieldKeyName] is List) {
      // ✅ Handle nested fields array
      final nestedFields = field[formFieldKeyName] as List;
      for (int i = 0; i < nestedFields.length; i++) {
        final nestedField = nestedFields[i];
        if (nestedField is Map<String, dynamic>) {
          _addFieldToRequest(
            formFieldKeyName,
            request,
            nestedField,
            '$fieldPrefix[$formFieldKeyName][$i]',
          );
        }
      }
    } else {
      // ✅ Normal values
      if (value != null) {
        request.fields['$fieldPrefix[value]'] = value.toString();
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
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: (isEncodedBody == true) ? jsonEncode(data) : data,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
  }) async {
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
    final request = http.MultipartRequest('PUT', Uri.parse(url));
    request.headers.addAll(header ?? {});
    request.headers.addAll(headers);
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    if (file != null) {
      final mimeType = _getMimeType(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          formFieldKeyName,
          file.path,
          contentType: mimeType,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    required String dataKey,
    required String currentPageKeyForCancelTokens,
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
  }) async {
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
    final request = http.MultipartRequest('PUT', Uri.parse(url));
    request.headers.addAll(header ?? {});
    request.headers.addAll(headers);
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    if (files?.isNotEmpty ?? false) {
      for (var file in files!) {
        final mimeType = _getMimeType(file.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            formFieldKeyName,
            file.path,
            contentType: mimeType,
          ),
        );
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: (isEncodedBody == true) ? jsonEncode(data) : data,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    required String dataKey,
    required String currentPageKeyForCancelTokens,
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
  }) async {
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
    final request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers.addAll(header ?? {});
    request.headers.addAll(headers);
    data.forEach((key, value) {
      request.fields[key] = value;
    });
    if (files?.isNotEmpty ?? false) {
      for (var file in files!) {
        final mimeType = _getMimeType(file.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            formFieldKeyName,
            file.path,
            contentType: mimeType,
          ),
        );
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
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
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<T>();
    }
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
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: isEncodedBody == true ? jsonEncode(data) : data,
      );
      return _handleResponse<T>(
        response: response,
        dataKey: dataKey,
        endpoint: url,
      );
    } catch (e) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<T>(
        error: e,
        endpoint: url,
        stackTrace: StackTrace.current,
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
    final bool isHasInternetConnection =
        await _internetConnectionService.hasConnection;
    if (isHasInternetConnection != true) {
      return _apiServiceHelper.handleHTTPConnectionError<String>();
    }

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

      // Create the request
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      // Send the request
      final streamedResponse = await request.send();

      // Check if the response is successful
      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        // Get the file
        final file = File(savePath);

        // Create the file directory if it doesn't exist
        final directory = file.parent;
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Open the file for writing
        final sink = file.openWrite();

        // Track progress
        final totalBytes = streamedResponse.contentLength ?? 0;
        int receivedBytes = 0;

        // Stream the response to the file
        await for (var chunk in streamedResponse.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;

          // Call progress callback if provided
          if (onReceiveProgress != null && totalBytes > 0) {
            onReceiveProgress(receivedBytes, totalBytes);
          }
        }

        // Close the file
        await sink.close();

        return OperationResult<String>(
          data: savePath,
          statusCode: streamedResponse.statusCode,
          success: true,
          message: 'File downloaded successfully',
        );
      } else {
        return OperationResult<String>(
          statusCode: streamedResponse.statusCode,
          success: false,
          message: 'Failed to download file: ${streamedResponse.reasonPhrase}',
        );
      }
    } catch (e, st) {
      return _apiServiceHelper.handleHTTPApiCallsErrorsMethod<String>(
        error: e,
        endpoint: url,
        stackTrace: st,
      );
    }
  }

  MediaType? _getMimeType(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType == null) return null;
    final parts = mimeType.split('/');
    return MediaType(parts[0], parts[1]);
  }

  OperationResult<T> _handleResponse<T>({
    required http.Response response,
    required String dataKey,
    required String endpoint,
  }) {
    dynamic decodedResponse;
    try {
      decodedResponse = jsonDecode(response.body);
    } catch (e) {
      // Fallback if response is plain text or not JSON
      decodedResponse = response.body;
    }
    ApiLogger.logResponse(
      endpoint: endpoint,
      response: decodedResponse,
      statusCode: response.statusCode,
      headers: response.headers,
    );
    // Handle unauthorized responses
    if (response.statusCode == 401 &&
        _apiServiceHelper.unauthrizedCallback != null) {
      _apiServiceHelper.unauthrizedCallback!(decodedResponse);
      return OperationResult<T>(
        statusCode: response.statusCode,
        success: false,
        message: 'Unauthorized',
        responseHeaders: response.headers,
      );
    }

    // Successful response
    final bool isSuccess =
        response.statusCode >= 200 && response.statusCode < 300;
    try {
      // Handle when T is String and response is plain text
      if (T == String && decodedResponse is String) {
        return OperationResult<T>(
          data: decodedResponse as T,
          statusCode: response.statusCode,
          success: isSuccess,
          responseHeaders: response.headers,
        );
      }

      // Handle expected JSON Map with dataKey
      if (decodedResponse is Map<String, dynamic>) {
        final dynamic extractedData =
            decodedResponse[dataKey] ?? decodedResponse;

        return OperationResult<T>(
          data: extractedData as T,
          statusCode: response.statusCode,
          success: isSuccess,
          message: decodedResponse['message']?.toString(),
          messageAr: decodedResponse['message_ar']?.toString(),
          messageUr: decodedResponse['message_ur']?.toString(),
          responseHeaders: response.headers,
        );
      }

      // ✅ Handle List<Map<String, dynamic>> directly
      if (decodedResponse is List &&
          decodedResponse.every((e) => e is Map<String, dynamic>)) {
        try {
          final parsedList = List<Map<String, dynamic>>.from(decodedResponse);
          return OperationResult<T>(
            data: parsedList as T,
            statusCode: response.statusCode,
            success: isSuccess,
            responseHeaders: response.headers,
          );
        } catch (e) {
          return OperationResult<T>(
            statusCode: response.statusCode,
            success: false,
            message: 'Error casting list of objects to expected type: $e',
            responseHeaders: response.headers,
          );
        }
      }

      // Handle List or other types
      if (decodedResponse is T) {
        return OperationResult<T>(
          data: decodedResponse,
          statusCode: response.statusCode,
          success: isSuccess,
          responseHeaders: response.headers,
        );
      }

      return OperationResult<T>(
        statusCode: response.statusCode,
        success: false,
        message:
            'Unexpected response format. Expected type: $T, but got: ${decodedResponse.runtimeType}',
        responseHeaders: response.headers,
      );
    } catch (e, stackTrace) {
      ApiLogger.logError(
        endpoint: endpoint,
        error: e,
        stackTrace: stackTrace,
        statusCode: response.statusCode,
      );

      return OperationResult<T>(
        statusCode: response.statusCode,
        success: false,
        message: 'Error processing response: ${e.toString()}',
        responseHeaders: response.headers,
      );
    }
  }

  @override
  void cancelCurrentPageRequests({
    required String currentPageKeyForCancelTokens,
  }) {}

  @override
  void cancelAllRequests() {}

  /// No-op: [HttpApiService] has no response cache.
  @override
  Future<void> clearCache() async {}
}
