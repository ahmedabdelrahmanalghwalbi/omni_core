part of '../../omni_core.dart';

abstract class FormatePhoneNumberUtils {
  /// Formats a phone number for server usage by removing the '+' sign
  /// and converting it to E.164 international format.
  ///
  /// Example:
  ///   phoneNumber = "01067058288"
  ///   countryCode = "EG"
  ///   Result = "201067058288"
  static String? formatPhoneNumberForServer({
    required String phoneNumber,
    required IsoCode countryIsoCode,
  }) {
    try {
      final parsedPhone = PhoneNumber.parse(
        phoneNumber,
        callerCountry: countryIsoCode,
      );
      return '${parsedPhone.countryCode}${parsedPhone.nsn}';
    } catch (e) {
      // You can log or handle the error here if needed
      return null;
    }
  }
}
