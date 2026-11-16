part of '../../omni_core.dart';

class PackageLogger {
  static void debug(dynamic message, {String tag = '🐛 PACKAGE DEBUG'}) {
    if (kDebugMode) {
      developer.log('🐛 $message', name: tag, level: 500);
    }
  }

  static void info(dynamic message, {String tag = 'ℹ️ PACKAGE INFO'}) {
    if (kDebugMode) {
      developer.log('ℹ️ $message', name: tag, level: 800);
    }
  }

  static void warning(dynamic message, {String tag = '⚠️ PACKAGE WARNING'}) {
    if (kDebugMode) {
      developer.log('⚠️ $message', name: tag, level: 900);
    }
  }

  static void error(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = '❌ PACKAGE ERROR',
  }) {
    if (kDebugMode) {
      developer.log(
        '❌ $message',
        name: tag,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }
}
