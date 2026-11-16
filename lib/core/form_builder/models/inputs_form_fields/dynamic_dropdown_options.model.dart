part of '../../../../omni_core.dart';

/// Contract the host app implements to load options for dynamic dropdowns,
/// typically by calling `GET /api/v1/form-entities/{entityKey}/data` with
/// [DynamicDropdownOptionsRequestModel.toQueryParameters].
///
/// Return `null` (or throw) to signal a failed load; the field then shows a
/// retry state.
typedef DynamicDropdownOptionsFetcher =
    Future<DynamicDropdownOptionsPageModel?> Function(
      DynamicDropdownOptionsRequestModel request,
    );

/// A single page request of dynamic dropdown options.
class DynamicDropdownOptionsRequestModel {
  final String entityKey;
  final String? displayField;
  final int limit;
  final int offset;
  final String? search;
  final String? parentEntityKey;

  /// The parent's selected id (primitive), never the full selection object.
  final Object? parentValue;

  /// Extra entity properties to return with every option, so a derived field
  /// can read them from the selection without another request — and still read
  /// them offline.
  final List<String> includeProperties;

  const DynamicDropdownOptionsRequestModel({
    required this.entityKey,
    this.displayField,
    this.limit = 50,
    this.offset = 0,
    this.search,
    this.parentEntityKey,
    this.parentValue,
    this.includeProperties = const [],
  });

  /// Query parameters expected by the form-entities data endpoint.
  Map<String, String> toQueryParameters() => {
    if (displayField?.isNotEmpty ?? false) 'displayField': displayField!,
    'limit': '$limit',
    'offset': '$offset',
    if (search?.isNotEmpty ?? false) 'search': search!,
    if (parentEntityKey?.isNotEmpty ?? false)
      'parentEntityKey': parentEntityKey!,
    if (parentValue != null) 'parentValue': '$parentValue',
    if (includeProperties.isNotEmpty)
      'includeProperties': includeProperties.join(','),
  };
}

/// A single page of dynamic dropdown options, where each item is expected to
/// contain `id` and `displayValue`.
class DynamicDropdownOptionsPageModel {
  final List<Map<String, dynamic>> items;
  final bool hasMore;

  const DynamicDropdownOptionsPageModel({
    required this.items,
    this.hasMore = false,
  });

  /// Parses the form-entities data endpoint response body.
  DynamicDropdownOptionsPageModel.fromJson(Map<String, dynamic>? json)
    : items = json?['data'] is List
          ? (json!['data'] as List).whereType<Map<String, dynamic>>().toList()
          : const [],
      hasMore = AppBaseModel.parseBool(json?['hasMore']) ?? false;
}
