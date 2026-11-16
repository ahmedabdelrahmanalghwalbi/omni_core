part of '../../omni_core.dart';

class LanguageSwitcherWidget extends StatelessWidget {
  final BuildContext context;
  final Color primaryColor;
  final String arabicButtonText;
  final String englishButtonText;

  /// Optional label for Urdu. Required only when 'ur' is part of
  /// [supportedLanguageCodes]; ignored otherwise.
  final String? urduButtonText;

  /// Ordered language codes the button cycles through, wrapping back to the
  /// first entry. Defaults to the original English/Arabic toggle so existing
  /// apps keep their behavior unchanged.
  final List<String> supportedLanguageCodes;

  const LanguageSwitcherWidget({
    super.key,
    required this.context,
    required this.primaryColor,
    required this.arabicButtonText,
    required this.englishButtonText,
    this.urduButtonText,
    this.supportedLanguageCodes = const ['en', 'ar'],
  });

  Locale _nextLocale() {
    final current = context.locale.languageCode;
    final currentIndex = supportedLanguageCodes.indexOf(current);
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % supportedLanguageCodes.length;
    return Locale(supportedLanguageCodes[nextIndex]);
  }

  String _labelFor(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return arabicButtonText;
      case 'ur':
        return urduButtonText ?? englishButtonText;
      case 'en':
      default:
        return englishButtonText;
    }
  }

  @override
  Widget build(_) {
    final nextLocale = _nextLocale();
    return Container(
      margin: const EdgeInsets.only(bottom: 18.0),
      child: ElevatedButton(
        onPressed: () => context.setLocale(nextLocale),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.withAlpha(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          elevation: 0,
        ),
        child: Row(
          spacing: 8.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: primaryColor, size: 16.0),
            Text(
              _labelFor(nextLocale.languageCode),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
