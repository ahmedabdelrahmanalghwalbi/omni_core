part of '../../omni_core.dart';

abstract class CameraUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> takeSelfie({
    required BuildContext context,
    required String cameraPermissionRequiredTitleText,
    required String cameraPermissionRequiredMessageText,
    required String cameraPermissionCancelText,
    required String cameraPermissionOpenSettingsText,
    bool? silent,
  }) async {
    try {
      // 1️⃣ Check camera permission first
      final hasPermission = await _checkCameraRequirements(
        context: context,
        cameraPermissionRequiredTitleText: cameraPermissionRequiredTitleText,
        cameraPermissionRequiredMessageText:
            cameraPermissionRequiredMessageText,
        cameraPermissionCancelText: cameraPermissionCancelText,
        cameraPermissionOpenSettingsText: cameraPermissionOpenSettingsText,
        silent: silent,
      );

      if (!hasPermission) {
        PackageLogger.info('Camera permission not granted');
        if (silent != true) {
          ToastUtils.showWarning(cameraPermissionRequiredTitleText);
        }
        return null;
      }

      // 2️⃣ Open the front camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 90,
      );

      return image != null ? File(image.path) : null;
    } catch (err, ex) {
      PackageLogger.error('Failed to take selfie', error: err, stackTrace: ex);
      return null;
    }
  }

  /// Check and request camera permission
  static Future<bool> _checkCameraRequirements({
    required BuildContext context,
    required String cameraPermissionRequiredTitleText,
    required String cameraPermissionRequiredMessageText,
    required String cameraPermissionCancelText,
    required String cameraPermissionOpenSettingsText,
    bool? silent,
  }) async {
    // 1. Check current camera permission
    final permissionStatus = await Permission.camera.status;

    if (permissionStatus.isGranted) return true;

    // 2. Request permission
    final result = await Permission.camera.request();

    // 3. Handle permanently denied
    if (result.isPermanentlyDenied && context.mounted) {
      await _showPermissionDeniedDialog(
        context: context,
        cameraPermissionRequiredTitleText: cameraPermissionRequiredTitleText,
        cameraPermissionRequiredMessageText:
            cameraPermissionRequiredMessageText,
        cameraPermissionCancelText: cameraPermissionCancelText,
        cameraPermissionOpenSettingsText: cameraPermissionOpenSettingsText,
      );
      return false;
    }

    // 4. Handle temporarily denied
    if (!result.isGranted) {
      PackageLogger.warning('❌ Camera permission denied');
      if (silent != true) {
        ToastUtils.showWarning(cameraPermissionRequiredTitleText);
      }
      return false;
    }

    return true;
  }

  /// Dialog to open settings when permission is permanently denied
  static Future<void> _showPermissionDeniedDialog({
    required BuildContext context,
    required String cameraPermissionRequiredTitleText,
    required String cameraPermissionRequiredMessageText,
    required String cameraPermissionCancelText,
    required String cameraPermissionOpenSettingsText,
  }) async {
    await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cameraPermissionRequiredTitleText),
        content: Text(cameraPermissionRequiredMessageText),
        actions: [
          TextButton(
            child: Text(cameraPermissionCancelText),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(cameraPermissionOpenSettingsText),
            onPressed: () async {
              try {
                Navigator.pop(context);
                await openAppSettings();
              } catch (ex, st) {
                PackageLogger.error(
                  'Failed to open app settings',
                  error: ex,
                  stackTrace: st,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
