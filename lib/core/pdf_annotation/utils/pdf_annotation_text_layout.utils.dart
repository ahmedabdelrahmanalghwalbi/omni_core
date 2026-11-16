part of '../../../omni_core.dart';

/// Lays out a text annotation for a page of a given width.
///
/// The editor and the PDF export share this, so saved text wraps and sizes
/// exactly as it was shown on screen.
abstract class PdfAnnotationTextLayoutUtils {
  static TextPainter layout({
    required PdfTextAnnotationModel annotation,
    required double pageWidth,
  }) => TextPainter(
    text: TextSpan(
      text: annotation.text,
      style: TextStyle(
        color: annotation.color,
        fontSize: annotation.fontSizeFactor * pageWidth,
        height: 1.2,
      ),
    ),
    textDirection: annotation.textDirection,
  )..layout(maxWidth: _availableWidth(annotation, pageWidth));

  static Rect bounds({
    required PdfTextAnnotationModel annotation,
    required Size pageSize,
  }) {
    final painter = layout(annotation: annotation, pageWidth: pageSize.width);
    final bounds =
        Offset(
          annotation.position.dx * pageSize.width,
          annotation.position.dy * pageSize.height,
        ) &
        painter.size;
    painter.dispose();
    return bounds;
  }

  static double _availableWidth(
    PdfTextAnnotationModel annotation,
    double pageWidth,
  ) {
    final minWidth = annotation.fontSizeFactor * pageWidth;
    return max(minWidth, (1 - annotation.position.dx) * pageWidth);
  }
}
