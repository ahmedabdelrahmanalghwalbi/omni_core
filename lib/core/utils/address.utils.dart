part of '../../omni_core.dart';

abstract class AddressUtils {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static final Geocoding _geocoding = Geocoding();

  /// Your LocationIQ API key (keep secure in production)
  static const String _locationIQApiKey = 'pk.15f1f48234676853391f9b9195e0370d';

  /// Gets the address from coordinates using:
  /// 1. OSM
  /// 2. LocationIQ
  /// 3. Native geocoding (geocoding package)
  static Future<String> getAddressFromCoordinates(
    double lat,
    double lng, {
    String languageCode = 'en',
  }) async {
    try {
      final osmAddress = await _getAddressFromOSM(lat, lng, languageCode);
      if (osmAddress != null) return osmAddress;

      final locationIQAddress = await _getAddressFromLocationIQ(
        lat,
        lng,
        languageCode,
      );
      if (locationIQAddress != null) return locationIQAddress;

      return await _getAddressUsingNativeGeocoder(lat, lng, languageCode);
    } catch (e, s) {
      PackageLogger.error(
        'Unexpected error while getting address',
        error: e,
        stackTrace: s,
      );
      return 'Location unavailable';
    }
  }

  /// 1. Get address from OpenStreetMap (Nominatim)
  static Future<String?> _getAddressFromOSM(
    double lat,
    double lng,
    String languageCode,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'format': 'json', 'lat': lat, 'lon': lng},
        options: Options(
          headers: {
            'Accept-Language': languageCode,
            'User-Agent': 'FlutterApp',
          },
        ),
      );

      if (response.statusCode == 200) {
        final address = response.data['display_name'] as String?;
        return (address != null && address.isNotEmpty) ? address : null;
      }
    } catch (e, s) {
      PackageLogger.error(
        'OSM reverse geocoding failed',
        error: e,
        stackTrace: s,
      );
    }
    return null;
  }

  /// 2. Get address from LocationIQ
  static Future<String?> _getAddressFromLocationIQ(
    double lat,
    double lng,
    String languageCode,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        'https://us1.locationiq.com/v1/reverse',
        queryParameters: {
          'key': _locationIQApiKey,
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'accept-language': languageCode,
        },
      );

      if (response.statusCode == 200) {
        final address = response.data['display_name'] as String?;
        return (address != null && address.isNotEmpty) ? address : null;
      }
    } catch (e, s) {
      PackageLogger.error(
        'LocationIQ reverse geocoding failed',
        error: e,
        stackTrace: s,
      );
    }
    return null;
  }

  /// 3. Native geocoding fallback
  static Future<String> _getAddressUsingNativeGeocoder(
    double lat,
    double lng,
    String languageCode,
  ) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        lat,
        lng,
        locale: Locale(languageCode),
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final address = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

        return address.isNotEmpty ? address : 'Location unavailable';
      }
    } catch (e, s) {
      PackageLogger.error('Native geocoding failed', error: e, stackTrace: s);
    }
    return 'Location unavailable';
  }
}
