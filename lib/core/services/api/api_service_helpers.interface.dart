part of '../../../omni_core.dart';

/// Defines the supported request content types used in HTTP requests.
enum RequestContentType {
  /// Indicates the request body will be in JSON format (`application/json`).
  json,

  /// Indicates the request body will be URL encoded (`application/x-www-form-urlencoded`).
  formUrlEncoded,
}

/// Defines the supported response acceptance types for HTTP requests.
enum RequestAcceptanceType {
  /// Accept only JSON responses (`application/json`).
  json,

  /// Accept all response types (`*/*`).
  all,
}

/// Defines the supported cache strategies for HTTP requests.
///
/// Each value controls how the app interacts with:
/// - Network (API calls)
/// - Local cache (stored responses)
///
/// These strategies are typically mapped to Dio cache policies.
enum RequestCacheTypes {
  /// Default behavior.
  ///
  /// - Tries to fetch data from the network first.
  /// - May return cached data depending on cache configuration and headers.
  /// - Stores the response in cache after a successful request.
  ///
  /// Use when you want generally fresh data with standard caching.
  request,

  /// Cache-only mode.
  ///
  /// - Does NOT call the network.
  /// - Returns data only from cache.
  /// - Throws an error if no cached data is available.
  ///
  /// Ideal for full offline mode.
  forceCache,

  /// Network-only refresh with cache update.
  ///
  /// - Ignores any existing cache.
  /// - Always fetches fresh data from the network.
  /// - Updates the cache with the new response.
  ///
  /// Use for pull-to-refresh or critical fresh data.
  refresh,

  /// No caching at all.
  ///
  /// - Does NOT read from cache.
  /// - Does NOT write to cache.
  /// - Always performs a network request.
  ///
  /// Suitable for sensitive or one-time requests (e.g., login, OTP).
  noCache,

  /// Network-first with cache fallback.
  ///
  /// - Attempts to fetch data from the network.
  /// - If the network request fails, returns cached data if available.
  /// - Updates cache when network call succeeds.
  ///
  /// Recommended for most real-world scenarios:
  /// provides fresh data online and fallback when offline.
  refreshForceCache,
}

/// Contract that defines helper methods for building API client headers,
/// handling authentication, and providing error-handling strategies.
abstract class IApiServiceHelpers {
  /// Builds and returns the request headers to be sent with API calls.
  ///
  /// This method is responsible for setting common headers such as:
  /// - `Accept` header based on [acceptanceType].
  /// - `Content-Type` header based on [contentType].
  /// - Authentication headers (Bearer token or Basic Auth) if required.
  ///
  /// Parameters:
  /// - [additionalHeaders]: Optional key-value pairs to merge with default headers.
  /// - [addToken]: Whether to include a Bearer token in the headers.
  /// - [addSessionCookie]: Whether to include a session token (via cookies).
  /// - [isBasicAuth]: Whether to use Basic Authentication instead of Bearer.
  /// - [basicUsername] / [basicPassword]: Explicit Basic Auth credentials.
  /// - [contentType]: Determines the `Content-Type` header.
  /// - [acceptanceType]: Determines the `Accept` header.
  ///
  /// Returns:
  /// A `Future<Map<String, String>>` containing the complete set of headers.
  Future<Map<String, String>> buildHeadersMethod({
    Map<String, dynamic>? additionalHeaders,
    bool? addToken = true,
    bool? addSessionCookie = false,
    bool isBasicAuth = false,
    String? basicUsername,
    String? basicPassword,
    RequestContentType contentType = RequestContentType.json,
    RequestAcceptanceType acceptanceType = RequestAcceptanceType.json,
  });

  /// Callback invoked when the API responds with an **unauthorized (401)** error.
  ///
  /// Typically used to:
  /// - Trigger a re-login flow.
  /// - Refresh expired tokens.
  /// - Redirect the user to the login screen.
  ///
  /// Parameters:
  /// - ['response']: The raw unauthorized response from the API.
  void Function(dynamic response)? unauthrizedCallback;

  /// [HTTP SERVICE] Handles unexpected API call errors .
  OperationResult<T> handleHTTPApiCallsErrorsMethod<T>({
    required dynamic error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [HTTP SERVICE] Handles connection errors.
  OperationResult<T> handleHTTPConnectionError<T>();

  /// [DIO SERVICE] Handles unexpected API call errors .
  OperationResult<T> handleDIOApiCallsErrorsMethod<T>({
    required dynamic error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( No internet connection - DNS resolution fails - Server is unreachable - Network interface is down - Airplane mode is on - etc ).
  OperationResult<T> handleDIOConnectionError<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( When the server doesn't respond within connectTimeout - Different from network being unavailable ).
  OperationResult<T> handleDIOConnectionTimeout<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( When sending data times out (upload/request body) - Large file uploads often trigger this ).
  OperationResult<T> handleDIOSendTimeout<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( When receiving data times out (download/response body) - Large file downloads or slow server responses often trigger this ).
  OperationResult<T> handleDIOReceiveTimeout<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( SSL/TLS certificate validation fails - elf-signed certificates - Expired certificates - Certificate doesn't match domain ).
  OperationResult<T> handleDIOBadCertificate<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( Server responds with HTTP error (4xx, 5xx) - Sub-status codes to handle ( 400: Bad Request - 401: Unauthorized - 403: Forbidden - 404: Not Found - 408: Request Timeout - 429: Too Many Requests (Rate limiting) - 500: Internal Server Error - 502: Bad Gateway - 503: Service Unavailable - 504: Gateway Timeout ) ).
  OperationResult<T> handleDIOBadResponse<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( When the request is cancelled by the user - User navigated away from screen - Manual cancellation - etc ).
  OperationResult<T> handleDIOCancelledRequest<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });

  /// [DIO SERVICE] Handles unexpected API call errors ( Catch-all for unexpected errors for example ( JSON parsing failed - Type cast error - SSL handshake failed - TLS protocol error - etc. ).
  OperationResult<T> handleDIOUnknownError<T>({
    required DioException error,
    required String endpoint,
    required StackTrace stackTrace,
  });
}
