part of '../../omni_core.dart';

enum ToastType { success, error, warning, info }

abstract class ToastUtils {
  static void _show({
    required String message,
    ToastType type = ToastType.info,
    int autoCloseDurationInSeconds = 3,
  }) {
    toastification.dismissAll();
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      overlayState: AppRouter.navigatorKey.currentState?.overlay,
      autoCloseDuration: Duration(seconds: autoCloseDurationInSeconds),
      animationDuration: const Duration(milliseconds: 700),
      showProgressBar: true,
      progressBarTheme: legacy_material.ProgressIndicatorThemeData(
        color: Colors.white,
        strokeWidth: 1.0,
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        linearTrackColor: Colors.white.withAlpha(100),
      ),
      showIcon: true,
      icon: _getIcon(type),
      alignment: Alignment.topCenter,
      primaryColor: _getBackgroundColor(type),
      backgroundColor: _getBackgroundColor(type),
      foregroundColor: Colors.white,
      pauseOnHover: true,
      dragToClose: true,
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
      title: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        maxLines: 10,
      ),
      callbacks: ToastificationCallbacks(
        onAutoCompleteCompleted: (toastItem) =>
            PackageLogger.info('Toast ${toastItem.id} completed'),
        onDismissed: (toastItem) =>
            PackageLogger.info('Toast ${toastItem.id} dismissed'),
      ),
      closeOnClick: true,
      closeButton: ToastCloseButton(
        buttonBuilder: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  static void showSuccess(
    String message, {
    int autoCloseDurationInSeconds = 3,
  }) {
    _show(
      message: message,
      type: ToastType.success,
      autoCloseDurationInSeconds: autoCloseDurationInSeconds,
    );
  }

  static void showError(String message, {int autoCloseDurationInSeconds = 3}) {
    _show(
      message: message,
      type: ToastType.error,
      autoCloseDurationInSeconds: autoCloseDurationInSeconds,
    );
  }

  static void showWarning(
    String message, {
    int autoCloseDurationInSeconds = 3,
  }) {
    _show(
      message: message,
      type: ToastType.warning,
      autoCloseDurationInSeconds: autoCloseDurationInSeconds,
    );
  }

  static void showInfo(String message, {int autoCloseDurationInSeconds = 3}) {
    _show(
      message: message,
      type: ToastType.info,
      autoCloseDurationInSeconds: autoCloseDurationInSeconds,
    );
  }

  static Color _getBackgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.withAlpha(240);
      case ToastType.error:
        return Colors.red.withAlpha(240);
      case ToastType.warning:
        return Colors.orange.withAlpha(240);
      case ToastType.info:
        return Colors.blue.withAlpha(240);
    }
  }

  static Icon _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.white,
          size: 30.0,
        );
      case ToastType.error:
        return const Icon(
          Icons.error_outline_rounded,
          color: Colors.white,
          size: 30.0,
        );
      case ToastType.warning:
        return const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
          size: 30.0,
        );
      case ToastType.info:
        return const Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
          size: 30.0,
        );
    }
  }
}
