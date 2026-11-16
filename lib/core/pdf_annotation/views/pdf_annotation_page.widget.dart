part of '../../../omni_core.dart';

/// One PDF page with its annotations and the input layer of the active tool.
class _PdfAnnotationPageWidget extends StatelessWidget {
  final PdfAnnotationTool tool;
  final List<PdfAnnotationModel> annotations;
  final PdfStrokeAnnotationModel? activeStroke;
  final Color progressColor;
  final Future<Uint8List?> Function(bool Function() isStillNeeded) loadImage;
  final void Function(PointerDownEvent event) onPointerDown;
  final void Function(PointerMoveEvent event) onPointerMove;
  final void Function(PointerUpEvent event) onPointerUp;
  final void Function(PointerCancelEvent event) onPointerCancel;
  final void Function(Offset position) onTextTap;

  const _PdfAnnotationPageWidget({
    required this.tool,
    required this.annotations,
    required this.activeStroke,
    required this.progressColor,
    required this.loadImage,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.onPointerCancel,
    required this.onTextTap,
  });

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      _PdfAnnotationPageImageWidget(
        progressColor: progressColor,
        loadImage: loadImage,
      ),
      RepaintBoundary(
        child: CustomPaint(
          painter: _PdfAnnotationPagePainter(
            annotations: annotations,
            activeStroke: activeStroke,
          ),
        ),
      ),
      switch (tool) {
        PdfAnnotationTool.pan => const SizedBox.shrink(),
        PdfAnnotationTool.text => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => onTextTap(details.localPosition),
        ),
        PdfAnnotationTool.pen ||
        PdfAnnotationTool.highlighter ||
        PdfAnnotationTool.eraser => Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: onPointerDown,
          onPointerMove: onPointerMove,
          onPointerUp: onPointerUp,
          onPointerCancel: onPointerCancel,
        ),
      },
    ],
  );
}

class _PdfAnnotationPageImageWidget extends StatefulWidget {
  final Color progressColor;
  final Future<Uint8List?> Function(bool Function() isStillNeeded) loadImage;

  const _PdfAnnotationPageImageWidget({
    required this.progressColor,
    required this.loadImage,
  });

  @override
  State<_PdfAnnotationPageImageWidget> createState() =>
      _PdfAnnotationPageImageWidgetState();
}

class _PdfAnnotationPageImageWidgetState
    extends State<_PdfAnnotationPageImageWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final imageBytes = await widget.loadImage(() => mounted);
    if (!mounted) return;
    setState(() {
      _imageBytes = imageBytes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _imageBytes;
    return ColoredBox(
      color: Colors.white,
      child: imageBytes != null
          ? Image.memory(
              imageBytes,
              fit: BoxFit.fill,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            )
          : Center(
              child: _isLoading
                  ? CircularProgressIndicator(color: widget.progressColor)
                  : const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
    );
  }
}

class _PdfAnnotationPagePainter extends CustomPainter {
  static const double _highlighterOpacity = 0.4;

  final List<PdfAnnotationModel> annotations;
  final PdfStrokeAnnotationModel? activeStroke;

  const _PdfAnnotationPagePainter({
    required this.annotations,
    required this.activeStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final annotation in annotations) {
      switch (annotation) {
        case PdfStrokeAnnotationModel():
          _paintStroke(canvas, size, annotation);
        case PdfTextAnnotationModel():
          _paintText(canvas, size, annotation);
      }
    }
    final stroke = activeStroke;
    if (stroke != null) _paintStroke(canvas, size, stroke);
  }

  void _paintStroke(Canvas canvas, Size size, PdfStrokeAnnotationModel stroke) {
    if (stroke.points.isEmpty) return;
    final strokeWidth = stroke.widthFactor * size.width;
    final paint = Paint()
      ..color = stroke.isHighlighter
          ? stroke.color.withValues(alpha: _highlighterOpacity)
          : stroke.color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final first = stroke.points.first;
    if (stroke.points.length == 1) {
      canvas.drawCircle(
        Offset(first.dx * size.width, first.dy * size.height),
        strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }
    final path = Path()..moveTo(first.dx * size.width, first.dy * size.height);
    for (final point in stroke.points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _paintText(Canvas canvas, Size size, PdfTextAnnotationModel annotation) {
    final painter = PdfAnnotationTextLayoutUtils.layout(
      annotation: annotation,
      pageWidth: size.width,
    );
    painter.paint(
      canvas,
      Offset(
        annotation.position.dx * size.width,
        annotation.position.dy * size.height,
      ),
    );
    painter.dispose();
  }

  @override
  bool shouldRepaint(_PdfAnnotationPagePainter oldDelegate) =>
      !identical(oldDelegate.annotations, annotations) ||
      !identical(oldDelegate.activeStroke?.points, activeStroke?.points);
}
