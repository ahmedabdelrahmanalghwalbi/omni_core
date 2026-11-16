part of '../../omni_core.dart';

class StringUtils {
  /// Returns up to 2 initials (e.g., "Ahmed Abdelrahman" → "AA", "Ahmed" → "A").
  static String? getInitials({required String? title}) {
    if (title == null || title.trim().isEmpty) return null;

    final parts = title.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;

    // Take first letter of the first word
    String initials = parts.first[0].toUpperCase();

    // Add the first letter of the second word (if exists)
    if (parts.length > 1) {
      initials += parts[1][0].toUpperCase();
    }

    // Ensure maximum of 2 letters
    if (initials.length > 2) {
      initials = initials.substring(0, 2);
    }

    return initials;
  }

  static String buildHyphenatedString({String? str1, String? str2}) {
    // Trim values to avoid cases like "   "
    final s1 = str1?.trim();
    final s2 = str2?.trim();

    // Handle null or empty scenarios
    if (s1 == null || s1.isEmpty) {
      return s2 ?? '';
    }

    if (s2 == null || s2.isEmpty) {
      return s1;
    }

    // Both have values → return str1 - str2
    return '$s1 - $s2';
  }
}
