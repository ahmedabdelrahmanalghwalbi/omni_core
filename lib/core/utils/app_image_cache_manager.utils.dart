part of '../../omni_core.dart';

class AppImageCacheManagerUtils {
  static final CacheManager instance = CacheManager(
    Config(
      'appImageCache',
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 1000,
    ),
  );
}
