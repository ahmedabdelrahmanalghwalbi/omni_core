part of '../../omni_core.dart';

class LocationPermissionHandlerUtils {
  /// Checks if all required permissions and services are enabled
  /// Returns true if everything is ready for location tracking
  /// Returns false and shows appropriate dialogs if something is missing
  static Future<bool> checkLocationRequirements({
    required BuildContext context,
    required String locationServiceEnableLocationServicesText,
    required String locationServiceLocationServicesDisabledText,
    required String locationServiceCancelText,
    required String locationServiceOpenSettingsText,
    required String locationServiceLocationPermissionRequiredToTrackText,
    required String locationServiceLocationPermissionRequiredMessageText,
    required String locationServiceLocationPermissionRequiredTitleText,
    bool? silent,
  }) async {
    // 1. Check if location services are enabled
    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled && context.mounted) {
      await _showEnableLocationDialog(
        context: context,
        locationServiceCancelText: locationServiceCancelText,
        locationServiceEnableLocationServicesText:
            locationServiceEnableLocationServicesText,
        locationServiceLocationServicesDisabledText:
            locationServiceLocationServicesDisabledText,
        locationServiceOpenSettingsText: locationServiceOpenSettingsText,
        silent: silent,
      );
      return false;
    }

    // 2. Check location permissions
    final permissionStatus = await _checkLocationPermissions();
    if (permissionStatus != LocationPermission.always && context.mounted) {
      final granted = await _requestLocationPermission(
        context: context,
        locationServiceLocationPermissionRequiredToTrackText:
            locationServiceLocationPermissionRequiredToTrackText,
        locationServiceCancelText: locationServiceCancelText,
        locationServiceLocationPermissionRequiredMessageText:
            locationServiceLocationPermissionRequiredMessageText,
        locationServiceLocationPermissionRequiredTitleText:
            locationServiceLocationPermissionRequiredTitleText,
        locationServiceOpenSettingsText: locationServiceOpenSettingsText,
        silent: silent,
      );
      if (!granted) return false;
    }

    // 3. On Android, check if background location permission is granted (if needed)
    if (context.mounted && await _isAndroid(context: context)) {
      final backgroundPermissionStatus = await Permission.locationAlways.status;
      if (!backgroundPermissionStatus.isGranted && context.mounted) {
        final granted = await _requestBackgroundLocationPermission(
          context: context,
          locationServiceBackgroundPermissionRequiredText:
              locationServiceLocationPermissionRequiredToTrackText,
          locationServiceCancelText: locationServiceCancelText,
          locationServiceLocationPermissionRequiredMessageText:
              locationServiceLocationPermissionRequiredMessageText,
          locationServiceLocationPermissionRequiredTitleText:
              locationServiceLocationPermissionRequiredTitleText,
          locationServiceOpenSettingsText: locationServiceOpenSettingsText,
          silent: silent,
        );
        if (!granted) return false;
      }
    }

    // 4. On iOS, check if precise location is enabled (iOS 14+)
    if (context.mounted && await _isIOS(context: context)) {
      final isPreciseLocationEnabled = await Geolocator.getLocationAccuracy();
      if (isPreciseLocationEnabled == LocationAccuracyStatus.reduced &&
          context.mounted) {
        await _showEnablePreciseLocationDialog(
          context: context,
          locationServiceCancelText: locationServiceCancelText,
          locationServicePreciseLocationRequiredMessageText:
              locationServiceLocationPermissionRequiredMessageText,
          locationServicePreciseLocationRequiredTitleText:
              locationServiceLocationPermissionRequiredTitleText,
          locationServiceOpenSettingsText: locationServiceOpenSettingsText,
        );
        return false;
      }
    }

    return true;
  }

  static Future<bool> _isAndroid({required BuildContext context}) async =>
      Theme.of(context).platform == TargetPlatform.android;

  static Future<bool> _isIOS({required BuildContext context}) async =>
      Theme.of(context).platform == TargetPlatform.iOS;

  static Future<LocationPermission> _checkLocationPermissions() async =>
      Geolocator.checkPermission();

  static Future<bool> _requestLocationPermission({
    required BuildContext context,
    required String locationServiceLocationPermissionRequiredToTrackText,
    required String locationServiceLocationPermissionRequiredTitleText,
    required String locationServiceLocationPermissionRequiredMessageText,
    required String locationServiceCancelText,
    required String locationServiceOpenSettingsText,
    bool? silent,
  }) async {
    final status = await Geolocator.requestPermission();

    if (status == LocationPermission.deniedForever && context.mounted) {
      await _showPermissionDeniedDialog(
        context: context,
        locationServiceCancelText: locationServiceCancelText,
        locationServiceLocationPermissionRequiredMessageText:
            locationServiceLocationPermissionRequiredMessageText,
        locationServiceLocationPermissionRequiredTitleText:
            locationServiceLocationPermissionRequiredTitleText,
        locationServiceOpenSettingsText: locationServiceOpenSettingsText,
      );
      return false;
    }

    if (status == LocationPermission.denied) {
      PackageLogger.warning('❌ Location permission denied');
      if (silent != true) {
        ToastUtils.showWarning(
          locationServiceLocationPermissionRequiredToTrackText,
        );
      }
      return false;
    }

    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  static Future<bool> _requestBackgroundLocationPermission({
    required String locationServiceBackgroundPermissionRequiredText,
    required String locationServiceLocationPermissionRequiredTitleText,
    required String locationServiceLocationPermissionRequiredMessageText,
    required String locationServiceCancelText,
    required String locationServiceOpenSettingsText,
    required BuildContext context,
    bool? silent,
  }) async {
    final status = await Permission.locationAlways.request();

    if (status.isPermanentlyDenied && context.mounted) {
      await _showPermissionDeniedDialog(
        context: context,
        locationServiceCancelText: locationServiceCancelText,
        locationServiceLocationPermissionRequiredMessageText:
            locationServiceLocationPermissionRequiredMessageText,
        locationServiceLocationPermissionRequiredTitleText:
            locationServiceLocationPermissionRequiredTitleText,
        locationServiceOpenSettingsText: locationServiceOpenSettingsText,
      );
      return false;
    }

    if (status.isDenied) {
      PackageLogger.warning('❌ Background location permission denied');
      if (silent != true) {
        ToastUtils.showWarning(locationServiceBackgroundPermissionRequiredText);
      }
      return false;
    }

    return status.isGranted;
  }

  static Future<void> _showEnableLocationDialog({
    required String locationServiceEnableLocationServicesText,
    required String locationServiceLocationServicesDisabledText,
    required String locationServiceCancelText,
    required String locationServiceOpenSettingsText,
    required BuildContext context,
    bool? silent,
  }) async {
    await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locationServiceEnableLocationServicesText),
        content: Text(locationServiceLocationServicesDisabledText),
        actions: [
          TextButton(
            child: Text(locationServiceCancelText),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(locationServiceOpenSettingsText),
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.location);
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _showPermissionDeniedDialog({
    required BuildContext context,
    required String locationServiceLocationPermissionRequiredTitleText,
    required String locationServiceLocationPermissionRequiredMessageText,
    required String locationServiceCancelText,
    required String locationServiceOpenSettingsText,
  }) async {
    await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locationServiceLocationPermissionRequiredTitleText),
        content: Text(locationServiceLocationPermissionRequiredMessageText),
        actions: [
          TextButton(
            child: Text(locationServiceCancelText),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(locationServiceOpenSettingsText),
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _showEnablePreciseLocationDialog({
    required BuildContext context,
    required String locationServicePreciseLocationRequiredTitleText,
    required String locationServicePreciseLocationRequiredMessageText,
    required String locationServiceCancelText,
    required String locationServiceOpenSettingsText,
  }) async {
    await showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locationServicePreciseLocationRequiredTitleText),
        content: Text(locationServicePreciseLocationRequiredMessageText),
        actions: [
          TextButton(
            child: Text(locationServiceCancelText),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(locationServiceOpenSettingsText),
            onPressed: () async {
              try {
                Navigator.pop(context);
                await AppSettings.openAppSettings(
                  type: AppSettingsType.location,
                  asAnotherTask: true,
                );
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
