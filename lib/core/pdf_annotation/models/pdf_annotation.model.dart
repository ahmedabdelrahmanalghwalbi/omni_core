part of '../../../omni_core.dart';

enum PdfAnnotationTool { pan, pen, highlighter, text, eraser }

/// A mark the user added on top of a PDF page.
///
/// Every position is a fraction of the displayed page (0..1 on both axes) and
/// every size is a fraction of the page width, so an annotation keeps its
/// place at any zoom level and maps directly to PDF points when saved.
sealed class PdfAnnotationModel {
  final Color color;

  const PdfAnnotationModel({required this.color});
}

class PdfStrokeAnnotationModel extends PdfAnnotationModel {
  final List<Offset> points;
  final double widthFactor;
  final bool isHighlighter;

  const PdfStrokeAnnotationModel({
    required super.color,
    required this.points,
    required this.widthFactor,
    required this.isHighlighter,
  });
}

class PdfTextAnnotationModel extends PdfAnnotationModel {
  final Offset position;
  final String text;
  final double fontSizeFactor;
  final ui.TextDirection textDirection;

  const PdfTextAnnotationModel({
    required super.color,
    required this.position,
    required this.text,
    required this.fontSizeFactor,
    required this.textDirection,
  });
}
