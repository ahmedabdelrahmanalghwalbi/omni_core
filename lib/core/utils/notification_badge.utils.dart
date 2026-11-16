part of '../../omni_core.dart';

/// Centralized, platform-aware management of the application icon badge.
///
/// This is the single source of truth for notification badge operations across
/// all applications. It is exposed through static methods so callers never need
/// to instantiate or inject a service to update the badge.
///
/// Badge support is platform specific: iOS is fully handled through the platform
/// badge channel, Android launchers manage badges themselves (so the effect
/// there is limited), and unsupported platforms are treated as a no-op. The
/// implementation is intentionally structured so additional platform handling
/// can be introduced without changing any call sites.
abstract class NotificationBadgeUtils {
  static const String _logTag = 'Notification Badge Utils';
  static const Duration _timeout = Duration(seconds: 2);

  /// Clears the app icon badge counter.
  ///
  /// When [isIOSOnly] is `true` the badge is only cleared on iOS and the call
  /// is skipped on every other platform. When `false` the badge is cleared on
  /// any platform that supports it (iOS and Android).
  static Future<void> clearNotificationBadge({bool isIOSOnly = false}) =>
      setNotificationBadgeCount(0, isIOSOnly: isIOSOnly);

  /// Sets the app icon badge to [count].
  ///
  /// When [isIOSOnly] is `true` the badge is only updated on iOS and the call
  /// is skipped on every other platform. When `false` the badge is updated on
  /// any platform that supports it (iOS and Android).
  ///
  /// A [count] of zero (or negative) clears the badge. On Android the badge is
  /// managed by the launcher automatically, so updating it has limited effect
  /// there. Safe to call on any platform: failures are swallowed so a badge
  /// update can never crash the app.
  static Future<void> setNotificationBadgeCount(
    int count, {
    bool isIOSOnly = false,
  }) async {
    try {
      if (isIOSOnly && !Platform.isIOS) {
        return;
      }
      final bool supported = await AppBadgePlus.isSupported().timeout(_timeout);
      if (supported) {
        await AppBadgePlus.updateBadge(count < 0 ? 0 : count).timeout(_timeout);
      }
    } catch (err, trace) {
      PackageLogger.error(
        '🔥 Failed to update notification badge',
        error: err,
        stackTrace: trace,
        tag: _logTag,
      );
    }
  }
}
