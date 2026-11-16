part of '../../omni_core.dart';

class AppBaseModel {
  // Safe parse for int values with error handling and nullability
  static int? parseInt(dynamic value) {
    try {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed;
      }
      return null;
    } catch (e, s) {
      PackageLogger.error('Error parsing int value', error: e, stackTrace: s);
      return null;
    }
  }

  // Safe parse for double values with error handling and nullability
  static double? parseDouble(dynamic value) {
    try {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing Double value',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  // Safe parse for num values with error handling and nullability
  static num? parseNum(dynamic value) {
    try {
      if (value is num) return value;
      if (value is String) return num.tryParse(value);
      return null;
    } catch (e, s) {
      PackageLogger.error('Error parsing num value', error: e, stackTrace: s);
      return null;
    }
  }

  // Safe parse for string values with error handling and nullability
  static String? parseString(dynamic value) {
    try {
      return value?.toString();
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing string value',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  // Safe parse for DateTime values with error handling and nullability
  static DateTime? parseDateTime(dynamic value) {
    try {
      if (value == null) return null;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        return parsed?.toLocal();
      }
      return null;
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing DateTime value',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  // Safe parse for boolean values with error handling and nullability
  static bool? parseBool(dynamic value) {
    try {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase().trim() == 'true';
      if (value is int) return value != 0;
      return null;
    } catch (e, s) {
      PackageLogger.error('Error parsing bool value', error: e, stackTrace: s);
      return null;
    }
  }

  // Safe toJson method for lists of models with error handling
  static List<T> parseList<T>({
    required dynamic data,
    required T Function(Map<String, dynamic>?) fromJson,
  }) {
    final List<T> result = [];
    if (data is List) {
      for (final item in data) {
        try {
          if (item is Map<String, dynamic>) {
            result.add(fromJson(item));
          } else if (item is Map) {
            result.add(fromJson(item.cast<String, dynamic>()));
          } else {
            PackageLogger.warning(
              'Skipped non-map item in parseList: ${item.runtimeType}',
            );
          }
        } catch (e, s) {
          PackageLogger.error(
            'Error parsing list item',
            error: e,
            stackTrace: s,
          );
        }
      }
    } else {
      PackageLogger.warning('Expected List Type, but got ${data.runtimeType}');
    }
    return result;
  }

  /// Helper: Parse List(String)
  static List<String>? parseStringList(dynamic list) {
    try {
      if (list is List) {
        return list.map((e) => e?.toString() ?? '').toList();
      }
      return null;
    } catch (e, s) {
      PackageLogger.error('Error parsing string list', error: e, stackTrace: s);
      return null;
    }
  }

  /// Helper: Parse List(int)
  static List<int>? parseIntList(dynamic list) {
    try {
      if (list is List) {
        return list.map((e) {
          if (e is int) return e;
          if (e is String) return int.tryParse(e) ?? 0;
          return 0;
        }).toList();
      }
      return null;
    } catch (e, s) {
      PackageLogger.error('Error parsing int list', error: e, stackTrace: s);
      return null;
    }
  }

  // Safe parse for Map<String, dynamic>
  static Map<String, dynamic>? parseMap(dynamic value) {
    try {
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.map((key, val) => MapEntry(key.toString(), val));
      }
      PackageLogger.warning(
        'Expected Map<String, dynamic>, but got ${value.runtimeType}',
      );
      return null;
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing Map<String, dynamic>',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  // Safe parse for List<dynamic>
  static List<dynamic>? parseDynamicList(dynamic value) {
    try {
      if (value == null) return null;
      if (value is List<dynamic>) return List<dynamic>.from(value);
      if (value is List) {
        // Handle any List type and ensure it's List<dynamic>
        return value.map((item) => item as dynamic).toList();
      }

      // Handle Iterable types
      if (value is Iterable<dynamic>) {
        return value.toList();
      }
      if (value is Iterable) {
        return value.cast<dynamic>().toList();
      }

      return null;
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing dynamic list from ${value.runtimeType}',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }
}
