part of '../../omni_core.dart';

abstract class ColorsUtils {
  /// Returns a random [Color] (excluding white or very light colors)
  static Color getRandomColor() {
    try {
      final random = Random();
      final color = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      // Use new API (r, g, b are doubles 0.0–1.0)
      final brightness =
          ((color.r * 255.0) * 0.299 +
              (color.g * 255.0) * 0.587 +
              (color.b * 255.0) * 0.114) /
          255.0;

      if (brightness > 0.85) {
        // Regenerate if color is too light
        return getRandomColor();
      }

      return color;
    } catch (_) {
      // In case of any unexpected error
      return Colors.grey;
    }
  }
}
