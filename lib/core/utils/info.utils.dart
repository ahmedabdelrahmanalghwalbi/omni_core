part of '../../omni_core.dart';

abstract class InfoUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static Future<String?> getDeviceId() async {
    if (Platform.isAndroid) {
      return (await _deviceInfo.androidInfo).id;
    }
    if (Platform.isIOS) {
      return (await _deviceInfo.iosInfo).identifierForVendor;
    }
    return null;
  }

  static Future<String?> getEnhancedDeviceId() async {
    String? uniqueId;
    if (Platform.isAndroid) {
      const _androidIdPlugin = AndroidId();
      final androidIdFromPlugin = await _androidIdPlugin.getId();
      final androidInfo = await _deviceInfo.androidInfo;
      if (androidIdFromPlugin?.isNotEmpty ?? false) {
        uniqueId =
            'android_'
            '${androidInfo.id}_'
            '$androidIdFromPlugin'
            '${androidInfo.model}_'
            '${androidInfo.board}_'
            '${androidInfo.hardware}_'
            '${androidInfo.device}_'
            '${androidInfo.product}_'
            '${androidInfo.brand}_';
      } else {
        uniqueId =
            'android_'
            '${androidInfo.id}_'
            '${androidInfo.model}_'
            '${androidInfo.board}_'
            '${androidInfo.hardware}_'
            '${androidInfo.device}_'
            '${androidInfo.product}_'
            '${androidInfo.brand}_';
      }
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      uniqueId =
          'ios_'
          '${iosInfo.identifierForVendor}_'
          '${iosInfo.model}_'
          '${iosInfo.name}_'
          '${iosInfo.systemName}_'
          '${iosInfo.systemVersion}';
    }
    return uniqueId;
  }

  static Future<Map<String, dynamic>?> getDeviceInfo() async {
    Map<String, dynamic>? deviceInfoMap;
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      final brand = androidInfo.brand;
      final model = androidInfo.model;
      final osVersion = androidInfo.version.sdkInt;
      final appVersion = await getAppVersion();
      deviceInfoMap = {
        'brand': brand,
        'model': model,
        'os': 'Android',
        'osVersion': osVersion,
        'appVersion': appVersion,
      };
    }
    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      final brand = iosInfo.model;
      final model = iosInfo.utsname.machine;
      final osVersion = iosInfo.systemVersion;
      final appVersion = await getAppVersion();
      deviceInfoMap = {
        'brand': brand,
        'model': model,
        'os': 'iOS',
        'osVersion': osVersion,
        'appVersion': appVersion,
      };
    }
    return deviceInfoMap;
  }

  static Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }
}
