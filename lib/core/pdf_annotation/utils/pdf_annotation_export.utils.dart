part of '../../../omni_core.dart';

/// Writes annotations into a copy of a PDF.
///
/// The original pages are kept as they are; strokes are appended as vector
/// content and texts as images, so the result looks the same in any viewer.
abstract class PdfAnnotationExportUtils {
  static const String _outputDirectoryName = 'annotated_pdfs';
  static const double _highlighterOpacity = 0.4;

  // Texts are rasterized by Flutter rather than drawn with a PDF font, so
  // any script the device can render (Arabic included) is saved correctly.
  static const double _textRasterPageWidth = 1800.0;

  /// Returns the annotated copy of [sourcePath], or null when it could not be
  /// written. Keys of [annotationsByPage] are zero-based page indexes.
  static Future<File?> export({
    required String sourcePath,
    required String outputFileName,
    required Map<int, List<PdfAnnotationModel>> annotationsByPage,
  }) async {
    try {
      final pages = <_PdfAnnotationExportPage>[];
      for (final entry in annotationsByPage.entries) {
        if (entry.value.isEmpty) continue;
        pages.add(await _buildExportPage(entry.key, entry.value));
      }

      final temporaryDirectory = await getTemporaryDirectory();
      final outputPath = path_package.join(
        temporaryDirectory.path,
        _outputDirectoryName,
        '${DateTime.now().millisecondsSinceEpoch}',
        path_package.basename(outputFileName),
      );

      // Parsing and re-serializing a PDF is CPU-bound and can take seconds
      // for large documents, so it runs off the UI isolate.
      await compute(
        _writeAnnotatedPdf,
        _PdfAnnotationExportRequest(
          sourcePath: sourcePath,
          outputPath: outputPath,
          pages: pages,
        ),
      );
      return File(outputPath);
    } catch (e, stackTrace) {
      PackageLogger.error(
        'Error exporting annotated PDF',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<_PdfAnnotationExportPage> _buildExportPage(
    int pageIndex,
    List<PdfAnnotationModel> annotations,
  ) async {
    final items = <Object>[];
    for (final annotation in annotations) {
      switch (annotation) {
        case PdfStrokeAnnotationModel():
          items.add(annotation);
        case PdfTextAnnotationModel():
          items.add(await _rasterizeText(annotation));
      }
    }
    return _PdfAnnotationExportPage(pageIndex: pageIndex, items: items);
  }

  static Future<_PdfAnnotationRasterizedText> _rasterizeText(
    PdfTextAnnotationModel annotation,
  ) async {
    final painter = PdfAnnotationTextLayoutUtils.layout(
      annotation: annotation,
      pageWidth: _textRasterPageWidth,
    );
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      max(1, painter.width.ceil()),
      max(1, painter.height.ceil()),
    );
    try {
      final pngData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (pngData == null) {
        throw StateError('Text annotation could not be encoded');
      }
      return _PdfAnnotationRasterizedText(
        position: annotation.position,
        widthFactor: image.width / _textRasterPageWidth,
        heightFactor: image.height / _textRasterPageWidth,
        pngBytes: pngData.buffer.asUint8List(),
      );
    } finally {
      image.dispose();
      picture.dispose();
      painter.dispose();
    }
  }

  static Future<void> _writeAnnotatedPdf(
    _PdfAnnotationExportRequest request,
  ) async {
    final document = syncfusion_pdf.PdfDocument(
      inputBytes: await File(request.sourcePath).readAsBytes(),
    );
    try {
      for (final exportPage in request.pages) {
        if (exportPage.pageIndex >= document.pages.count) continue;
        _drawPage(document.pages[exportPage.pageIndex], exportPage);
      }
      final outputFile = File(request.outputPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(await document.save(), flush: true);
    } finally {
      document.dispose();
    }
  }

  static void _drawPage(
    syncfusion_pdf.PdfPage page,
    _PdfAnnotationExportPage exportPage,
  ) {
    final graphics = page.graphics;
    final displaySize = _displaySize(page);
    final pageState = graphics.save();
    _applyDisplayTransform(graphics, page);
    for (final item in exportPage.items) {
      switch (item) {
        case PdfStrokeAnnotationModel():
          _drawStroke(graphics, item, displaySize);
        case _PdfAnnotationRasterizedText():
          graphics.drawImage(
            syncfusion_pdf.PdfBitmap(item.pngBytes),
            Rect.fromLTWH(
              item.position.dx * displaySize.width,
              item.position.dy * displaySize.height,
              item.widthFactor * displaySize.width,
              item.heightFactor * displaySize.width,
            ),
          );
      }
    }
    graphics.restore(pageState);
  }

  static bool _isSideways(syncfusion_pdf.PdfPage page) =>
      page.rotation == syncfusion_pdf.PdfPageRotateAngle.rotateAngle90 ||
      page.rotation == syncfusion_pdf.PdfPageRotateAngle.rotateAngle270;

  static Size _displaySize(syncfusion_pdf.PdfPage page) =>
      _isSideways(page) ? page.size.flipped : page.size;

  // Page graphics use the unrotated page space, while annotations are placed
  // on the page as it is displayed. This maps displayed coordinates onto a
  // page that carries a rotation.
  static void _applyDisplayTransform(
    syncfusion_pdf.PdfGraphics graphics,
    syncfusion_pdf.PdfPage page,
  ) {
    final size = page.size;
    switch (page.rotation) {
      case syncfusion_pdf.PdfPageRotateAngle.rotateAngle0:
        break;
      case syncfusion_pdf.PdfPageRotateAngle.rotateAngle90:
        graphics.translateTransform(0, size.height);
        graphics.rotateTransform(-90);
      case syncfusion_pdf.PdfPageRotateAngle.rotateAngle180:
        graphics.translateTransform(size.width, size.height);
        graphics.rotateTransform(180);
      case syncfusion_pdf.PdfPageRotateAngle.rotateAngle270:
        graphics.translateTransform(size.width, 0);
        graphics.rotateTransform(90);
    }
  }

  static void _drawStroke(
    syncfusion_pdf.PdfGraphics graphics,
    PdfStrokeAnnotationModel stroke,
    Size displaySize,
  ) {
    final points = stroke.points
        .map((p) => Offset(p.dx * displaySize.width, p.dy * displaySize.height))
        .toList();
    if (points.isEmpty) return;
    // A zero-length segment is skipped by some viewers; nudge a single tap
    // so it is saved as a visible dot.
    if (points.length == 1) points.add(points.first.translate(0.01, 0));

    final path = syncfusion_pdf.PdfPath();
    for (var i = 0; i < points.length - 1; i++) {
      path.addLine(points[i], points[i + 1]);
    }
    final pen = syncfusion_pdf.PdfPen(
      syncfusion_pdf.PdfColor(
        (stroke.color.r * 255).round(),
        (stroke.color.g * 255).round(),
        (stroke.color.b * 255).round(),
      ),
      width: stroke.widthFactor * displaySize.width,
      lineCap: syncfusion_pdf.PdfLineCap.round,
      lineJoin: syncfusion_pdf.PdfLineJoin.round,
    );

    final strokeState = graphics.save();
    if (stroke.isHighlighter) {
      graphics.setTransparency(
        _highlighterOpacity,
        mode: syncfusion_pdf.PdfBlendMode.multiply,
      );
    }
    graphics.drawPath(path, pen: pen);
    graphics.restore(strokeState);
  }
}

class _PdfAnnotationExportRequest {
  final String sourcePath;
  final String outputPath;
  final List<_PdfAnnotationExportPage> pages;

  const _PdfAnnotationExportRequest({
    required this.sourcePath,
    required this.outputPath,
    required this.pages,
  });
}

class _PdfAnnotationExportPage {
  final int pageIndex;

  /// Each item is a [PdfStrokeAnnotationModel] or a
  /// [_PdfAnnotationRasterizedText], in drawing order.
  final List<Object> items;

  const _PdfAnnotationExportPage({
    required this.pageIndex,
    required this.items,
  });
}

class _PdfAnnotationRasterizedText {
  final Offset position;
  final double widthFactor;
  final double heightFactor;
  final Uint8List pngBytes;

  const _PdfAnnotationRasterizedText({
    required this.position,
    required this.widthFactor,
    required this.heightFactor,
    required this.pngBytes,
  });
}
