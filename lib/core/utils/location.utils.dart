part of '../../omni_core.dart';

abstract class LocationUtils {
  static Future<Position?> getCurrentLocation({
    required BuildContext context,
    required String locationServiceLocationPermissionRequiredTitleText,
    required String locationServiceEnableLocationServicesText,
    required String locationServiceLocationServicesDisabledText,
    required String locationServiceCancelText,
    required String locationServiceOpenSettingsText,
    required String locationServiceLocationPermissionRequiredToTrackText,
    required String locationServiceLocationPermissionRequiredMessageText,
    bool? silent,
  }) async {
    final hasPermission =
        await LocationPermissionHandlerUtils.checkLocationRequirements(
          context: context,
          locationServiceCancelText: locationServiceCancelText,
          locationServiceEnableLocationServicesText:
              locationServiceEnableLocationServicesText,
          locationServiceLocationPermissionRequiredMessageText:
              locationServiceLocationPermissionRequiredMessageText,
          locationServiceLocationPermissionRequiredTitleText:
              locationServiceLocationPermissionRequiredTitleText,
          locationServiceLocationPermissionRequiredToTrackText:
              locationServiceLocationPermissionRequiredToTrackText,
          locationServiceLocationServicesDisabledText:
              locationServiceLocationServicesDisabledText,
          locationServiceOpenSettingsText: locationServiceOpenSettingsText,
          silent: silent,
        );
    if (!hasPermission) {
      PackageLogger.info('Location permission not granted');
      if (silent != true) {
        ToastUtils.showWarning(
          locationServiceLocationPermissionRequiredTitleText,
        );
      }
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
