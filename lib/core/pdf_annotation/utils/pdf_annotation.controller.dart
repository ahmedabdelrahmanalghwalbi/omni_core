part of '../../../omni_core.dart';

/// Holds the editing state of a PDF annotation session: the annotations of
/// every page, the selected tool and its options, and the undo/redo history.
class PdfAnnotationController extends ChangeNotifier {
  static const List<Color> palette = [
    Color(0xFF000000),
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFDD835),
    Color(0xFFFB8C00),
  ];
  static const List<double> strokeSizeScales = [0.5, 1.0, 2.0];

  static const double _penWidthFactor = 0.004;
  static const double _highlighterWidthFactor = 0.028;
  static const double _textFontSizeFactor = 0.028;
  static const double _minPointDistance = 0.001;
  static const int _maxHistoryLength = 100;

  Map<int, List<PdfAnnotationModel>> _annotationsByPage = {};
  final List<Map<int, List<PdfAnnotationModel>>> _undoStack = [];
  final List<Map<int, List<PdfAnnotationModel>>> _redoStack = [];

  PdfAnnotationTool _tool = PdfAnnotationTool.pan;
  final Map<PdfAnnotationTool, Color> _toolColors = {
    PdfAnnotationTool.pen: palette[1],
    PdfAnnotationTool.highlighter: palette[4],
    PdfAnnotationTool.text: palette[0],
  };
  int _strokeSizeIndex = 1;

  int? _activeStrokePageIndex;
  List<Offset> _activeStrokePoints = const [];

  PdfAnnotationTool get tool => _tool;
  int get strokeSizeIndex => _strokeSizeIndex;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  bool get hasAnnotations =>
      _annotationsByPage.values.any((annotations) => annotations.isNotEmpty);
  bool get isDrawingTool =>
      _tool == PdfAnnotationTool.pen || _tool == PdfAnnotationTool.highlighter;

  /// The color of the selected tool, or null when the tool has no color.
  Color? get toolColor => _toolColors[_tool];

  Map<int, List<PdfAnnotationModel>> get annotationsByPage =>
      Map.unmodifiable(_annotationsByPage);

  List<PdfAnnotationModel> annotationsOfPage(int pageIndex) =>
      _annotationsByPage[pageIndex] ?? const [];

  /// The stroke being drawn on the given page, if any.
  PdfStrokeAnnotationModel? activeStrokeOfPage(int pageIndex) =>
      _activeStrokePageIndex == pageIndex ? _buildActiveStroke() : null;

  void selectTool(PdfAnnotationTool tool) {
    if (_tool == tool) return;
    _discardActiveStroke();
    _tool = tool;
    notifyListeners();
  }

  void selectToolColor(Color color) {
    if (!_toolColors.containsKey(_tool) || _toolColors[_tool] == color) return;
    _toolColors[_tool] = color;
    notifyListeners();
  }

  void selectStrokeSize(int strokeSizeIndex) {
    if (strokeSizeIndex < 0 ||
        strokeSizeIndex >= strokeSizeScales.length ||
        strokeSizeIndex == _strokeSizeIndex) {
      return;
    }
    _strokeSizeIndex = strokeSizeIndex;
    notifyListeners();
  }

  void startStroke(int pageIndex, Offset point) {
    if (!isDrawingTool) return;
    _activeStrokePageIndex = pageIndex;
    _activeStrokePoints = [point];
    notifyListeners();
  }

  void extendStroke(Offset point) {
    if (_activeStrokePageIndex == null) return;
    if ((point - _activeStrokePoints.last).distance < _minPointDistance) {
      return;
    }
    _activeStrokePoints = [..._activeStrokePoints, point];
    notifyListeners();
  }

  void endStroke() {
    final pageIndex = _activeStrokePageIndex;
    final stroke = _buildActiveStroke();
    if (pageIndex == null || stroke == null) return;
    _discardActiveStroke();
    _commit(pageIndex, [...annotationsOfPage(pageIndex), stroke]);
  }

  void cancelStroke() {
    if (_activeStrokePageIndex == null) return;
    _discardActiveStroke();
    notifyListeners();
  }

  void addText({
    required int pageIndex,
    required Offset position,
    required String text,
    required ui.TextDirection textDirection,
  }) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;
    _commit(pageIndex, [
      ...annotationsOfPage(pageIndex),
      PdfTextAnnotationModel(
        color: _toolColors[PdfAnnotationTool.text]!,
        position: position,
        text: trimmedText,
        fontSizeFactor: _textFontSizeFactor,
        textDirection: textDirection,
      ),
    ]);
  }

  /// Removes the topmost annotation under [point], a position in logical
  /// pixels on a page displayed at [pageSize].
  void eraseAt({
    required int pageIndex,
    required Offset point,
    required Size pageSize,
    required double tolerance,
  }) {
    final annotations = annotationsOfPage(pageIndex);
    final hitIndex = annotations.lastIndexWhere(
      (annotation) => _isHit(annotation, point, pageSize, tolerance),
    );
    if (hitIndex < 0) return;
    _commit(pageIndex, [...annotations]..removeAt(hitIndex));
  }

  void undo() {
    if (!canUndo) return;
    _discardActiveStroke();
    _redoStack.add(_annotationsByPage);
    _annotationsByPage = _undoStack.removeLast();
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _discardActiveStroke();
    _undoStack.add(_annotationsByPage);
    _annotationsByPage = _redoStack.removeLast();
    notifyListeners();
  }

  // Page lists are replaced, never mutated, so a history entry can share
  // them with the current state.
  void _commit(int pageIndex, List<PdfAnnotationModel> pageAnnotations) {
    _undoStack.add(_annotationsByPage);
    if (_undoStack.length > _maxHistoryLength) _undoStack.removeAt(0);
    _redoStack.clear();
    _annotationsByPage = {..._annotationsByPage, pageIndex: pageAnnotations};
    notifyListeners();
  }

  PdfStrokeAnnotationModel? _buildActiveStroke() {
    final color = _toolColors[_tool];
    if (!isDrawingTool || color == null || _activeStrokePoints.isEmpty) {
      return null;
    }
    final isHighlighter = _tool == PdfAnnotationTool.highlighter;
    return PdfStrokeAnnotationModel(
      color: color,
      points: _activeStrokePoints,
      widthFactor:
          (isHighlighter ? _highlighterWidthFactor : _penWidthFactor) *
          strokeSizeScales[_strokeSizeIndex],
      isHighlighter: isHighlighter,
    );
  }

  void _discardActiveStroke() {
    _activeStrokePageIndex = null;
    _activeStrokePoints = const [];
  }

  bool _isHit(
    PdfAnnotationModel annotation,
    Offset point,
    Size pageSize,
    double tolerance,
  ) {
    switch (annotation) {
      case PdfTextAnnotationModel():
        return PdfAnnotationTextLayoutUtils.bounds(
          annotation: annotation,
          pageSize: pageSize,
        ).inflate(tolerance).contains(point);
      case PdfStrokeAnnotationModel():
        final reach = tolerance + annotation.widthFactor * pageSize.width / 2;
        final points = annotation.points
            .map((p) => Offset(p.dx * pageSize.width, p.dy * pageSize.height))
            .toList();
        if (points.length == 1) return (point - points.first).distance <= reach;
        for (var i = 0; i < points.length - 1; i++) {
          if (_distanceToSegment(point, points[i], points[i + 1]) <= reach) {
            return true;
          }
        }
        return false;
    }
  }

  double _distanceToSegment(Offset point, Offset start, Offset end) {
    final segment = end - start;
    final lengthSquared = segment.distanceSquared;
    if (lengthSquared == 0) return (point - start).distance;
    final projection =
        ((point.dx - start.dx) * segment.dx +
            (point.dy - start.dy) * segment.dy) /
        lengthSquared;
    final closest = start + segment * projection.clamp(0.0, 1.0);
    return (point - closest).distance;
  }
}
