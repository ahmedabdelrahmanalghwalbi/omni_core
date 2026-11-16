part of '../../../../omni_core.dart';

class DioApiCancelTokenManagerService {
  final Map<String, List<CancelToken>> _tokensMap = {};

  /// Register token for a specific page/view
  CancelToken createToken({required String pageKey}) {
    final token = CancelToken();
    if (!_tokensMap.containsKey(pageKey)) {
      _tokensMap[pageKey] = [];
    }
    _tokensMap[pageKey]!.add(token);
    return token;
  }

  /// Cancel all requests related to the page/view
  void cancelRequests({required String pageKey}) {
    if (_tokensMap.containsKey(pageKey)) {
      for (final token in _tokensMap[pageKey]!) {
        if (!token.isCancelled) {
          token.cancel('Cancelled api calls due to page change');
        }
      }
      _tokensMap.remove(pageKey);
    }
  }

  /// Cancel everything in the whole app (useful on logout)
  void cancelAll() {
    for (final list in _tokensMap.values) {
      for (final token in list) {
        if (!token.isCancelled) token.cancel('Cancelled all api calls');
      }
    }
    _tokensMap.clear();
  }
}
