part of '../../../omni_core.dart';

/// Full-screen editor that lets the user draw, highlight and write on a PDF.
///
/// Pops with the annotated copy as a [File] when the user saves, and with
/// nothing when the user leaves without saving. The source file is never
/// modified.
class PdfAnnotationEditorView extends StatefulWidget {
  final String filePath;

  /// File name of the annotated copy. Defaults to the name of [filePath].
  final String? outputFileName;
  final Color primaryColor;
  final PdfAnnotationTexts texts;

  const PdfAnnotationEditorView({
    super.key,
    required this.filePath,
    required this.primaryColor,
    this.outputFileName,
    this.texts = const PdfAnnotationTexts(),
  });

  @override
  State<PdfAnnotationEditorView> createState() =>
      _PdfAnnotationEditorViewState();
}

class _PdfAnnotationEditorViewState extends State<PdfAnnotationEditorView> {
  static const double _pageMargin = 12.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;
  static const double _eraserTolerance = 10.0;
  static const double _renderOversampling = 1.5;
  static const double _maxRenderWidth = 2000.0;
  static const int _renderQuality = 90;
  static const int _maxCachedPageImages = 8;
  static const Color _canvasColor = Color(0xFFE0E0E0);

  final PdfAnnotationController _annotationController =
      PdfAnnotationController();
  final TransformationController _transformationController =
      TransformationController();

  // Insertion-ordered, so the first key is always the oldest rendered page.
  final Map<int, Uint8List> _pageImageCache = {};

  pdfx.PdfDocument? _document;
  List<double> _pageAspectRatios = const [];
  bool _isLoading = true;
  bool _isSaving = false;

  // The platform renderers allow one open page at a time, so page renders
  // are chained instead of running concurrently.
  Future<void> _renderQueue = Future.value();

  int _activePointerCount = 0;
  int? _drawingPointer;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDocument());
  }

  @override
  void dispose() {
    _annotationController.dispose();
    _transformationController.dispose();
    unawaited(_closeDocument(_document));
    super.dispose();
  }

  Future<void> _loadDocument() async {
    pdfx.PdfDocument? document;
    try {
      document = await pdfx.PdfDocument.openFile(widget.filePath);
      if (document.pagesCount < 1) throw StateError('PDF has no pages');
      final aspectRatios = <double>[];
      for (var number = 1; number <= document.pagesCount; number++) {
        final page = await document.getPage(number);
        aspectRatios.add(page.width > 0 ? page.height / page.width : 1.0);
        await page.close();
      }
      if (!mounted) {
        await _closeDocument(document);
        return;
      }
      setState(() {
        _document = document;
        _pageAspectRatios = aspectRatios;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      PackageLogger.error(
        'Error opening PDF for annotation',
        error: e,
        stackTrace: stackTrace,
      );
      await _closeDocument(document);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _closeDocument(pdfx.PdfDocument? document) async {
    if (document == null || document.isClosed) return;
    try {
      await document.close();
    } catch (e, stackTrace) {
      PackageLogger.error(
        'Error closing annotated PDF',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Uint8List?> _loadPageImage({
    required int pageIndex,
    required double renderWidth,
    required bool Function() isStillNeeded,
  }) {
    final cachedImage = _pageImageCache[pageIndex];
    if (cachedImage != null) return Future.value(cachedImage);
    final render = _renderQueue.then(
      (_) => _renderPage(pageIndex, renderWidth, isStillNeeded),
    );
    _renderQueue = render;
    return render;
  }

  Future<Uint8List?> _renderPage(
    int pageIndex,
    double renderWidth,
    bool Function() isStillNeeded,
  ) async {
    final document = _document;
    if (document == null || document.isClosed || !isStillNeeded()) return null;
    try {
      final page = await document.getPage(pageIndex + 1);
      final pdfx.PdfPageImage? image;
      try {
        image = await page.render(
          width: renderWidth,
          height: renderWidth * _pageAspectRatios[pageIndex],
          format: pdfx.PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
          quality: _renderQuality,
        );
      } finally {
        await page.close();
      }
      final bytes = image?.bytes;
      if (bytes == null) return null;
      _pageImageCache[pageIndex] = bytes;
      if (_pageImageCache.length > _maxCachedPageImages) {
        _pageImageCache.remove(_pageImageCache.keys.first);
      }
      return bytes;
    } catch (e, stackTrace) {
      PackageLogger.error(
        'Error rendering PDF page',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  List<Rect> _layoutPages(double viewportWidth) {
    final pageWidth = max(1.0, viewportWidth - _pageMargin * 2);
    final pageRects = <Rect>[];
    var top = _pageMargin;
    for (final aspectRatio in _pageAspectRatios) {
      final pageHeight = pageWidth * aspectRatio;
      pageRects.add(Rect.fromLTWH(_pageMargin, top, pageWidth, pageHeight));
      top += pageHeight + _pageMargin;
    }
    return pageRects;
  }

  // Pages within half a screen of the viewport are kept built, so they are
  // already rendered when scrolled into view.
  Rect _visibleSceneRect(Size viewportSize) {
    final viewportInScene = Rect.fromPoints(
      _transformationController.toScene(Offset.zero),
      _transformationController.toScene(viewportSize.bottomRight(Offset.zero)),
    );
    return viewportInScene.inflate(viewportInScene.height / 2);
  }

  void _onViewerPointerDown(PointerDownEvent event) {
    _activePointerCount++;
    // A second finger means the user is zooming or scrolling, not drawing.
    if (_activePointerCount > 1) {
      _drawingPointer = null;
      _annotationController.cancelStroke();
    }
  }

  void _onViewerPointerEnd(PointerEvent event) {
    _activePointerCount = max(0, _activePointerCount - 1);
  }

  // Page listeners are notified before the viewer listener above, so the
  // pointer count here does not include the pointer of this event yet.
  void _onPagePointerDown(
    int pageIndex,
    Size pageSize,
    PointerDownEvent event,
  ) {
    if (_activePointerCount > 0) return;
    _drawingPointer = event.pointer;
    if (_annotationController.tool == PdfAnnotationTool.eraser) {
      _eraseAt(pageIndex, pageSize, event.localPosition);
    } else {
      _annotationController.startStroke(
        pageIndex,
        _toPageFraction(event.localPosition, pageSize),
      );
    }
  }

  void _onPagePointerMove(
    int pageIndex,
    Size pageSize,
    PointerMoveEvent event,
  ) {
    if (event.pointer != _drawingPointer) return;
    if (_annotationController.tool == PdfAnnotationTool.eraser) {
      _eraseAt(pageIndex, pageSize, event.localPosition);
    } else {
      _annotationController.extendStroke(
        _toPageFraction(event.localPosition, pageSize),
      );
    }
  }

  void _onPagePointerUp(PointerUpEvent event) {
    if (event.pointer != _drawingPointer) return;
    _drawingPointer = null;
    _annotationController.endStroke();
  }

  void _onPagePointerCancel(PointerCancelEvent event) {
    if (event.pointer != _drawingPointer) return;
    _drawingPointer = null;
    _annotationController.cancelStroke();
  }

  void _eraseAt(int pageIndex, Size pageSize, Offset position) {
    _annotationController.eraseAt(
      pageIndex: pageIndex,
      point: position,
      pageSize: pageSize,
      // Keeps the finger-sized reach constant on screen while zoomed in.
      tolerance:
          _eraserTolerance /
          _transformationController.value.getMaxScaleOnAxis(),
    );
  }

  Offset _toPageFraction(Offset position, Size pageSize) => Offset(
    (position.dx / pageSize.width).clamp(0.0, 1.0),
    (position.dy / pageSize.height).clamp(0.0, 1.0),
  );

  Future<void> _addTextAt(int pageIndex, Size pageSize, Offset position) async {
    final textDirection = Directionality.of(context);
    final text = await showDialog<String>(
      context: context,
      // A stray tap outside must not throw away a note being typed.
      barrierDismissible: false,
      builder: (_) => _PdfAnnotationTextDialogWidget(
        texts: widget.texts,
        primaryColor: widget.primaryColor,
      ),
    );
    if (text == null || !mounted) return;
    _annotationController.addText(
      pageIndex: pageIndex,
      position: _toPageFraction(position, pageSize),
      text: text,
      textDirection: textDirection,
    );
  }

  Future<void> _save() async {
    if (_isSaving || !_annotationController.hasAnnotations) return;
    setState(() => _isSaving = true);
    final annotatedFile = await PdfAnnotationExportUtils.export(
      sourcePath: widget.filePath,
      outputFileName:
          widget.outputFileName ?? path_package.basename(widget.filePath),
      annotationsByPage: _annotationController.annotationsByPage,
    );
    if (!mounted) return;
    if (annotatedFile == null) {
      setState(() => _isSaving = false);
      ToastUtils.showError(widget.texts.saveFailedMessage);
      return;
    }
    AppRouter.goBack<File>(result: annotatedFile);
  }

  Future<void> _confirmDiscardChanges() async {
    if (_isSaving) return;
    final shouldDiscard = await AppRouter.showConfirmMessageWithLogo(
      title: widget.texts.discardChangesTitle,
      message: widget.texts.discardChangesMessage,
      confirmText: widget.texts.discardChangesConfirm,
      denyText: widget.texts.cancel,
      confirmButtonColor: widget.primaryColor,
    );
    if (shouldDiscard && mounted) AppRouter.goBack<File>();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _annotationController,
    builder: (context, _) {
      final hasAnnotations = _annotationController.hasAnnotations;
      final tool = _annotationController.tool;
      final isReady = !_isLoading && _document != null;
      return PopScope(
        canPop: !hasAnnotations && !_isSaving,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_confirmDiscardChanges());
        },
        child: Scaffold(
          backgroundColor: _canvasColor,
          appBar: GeneralAppbarWidget(
            title: widget.texts.editorTitle,
            primaryColor: widget.primaryColor,
            showBackArrowButton: true,
            actions: [
              TextButton(
                onPressed: hasAnnotations && !_isSaving ? _save : null,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white54,
                ),
                child: Text(widget.texts.save),
              ),
            ],
          ),
          body: Stack(
            children: [
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(color: widget.primaryColor),
                )
              else if (!isReady)
                PlaceholderWidget(
                  title: widget.texts.loadFailedMessage,
                  retryButtonText: '',
                  primaryColor: widget.primaryColor,
                  icon: Icons.picture_as_pdf_outlined,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final viewportSize = constraints.biggest;
                    final pageRects = _layoutPages(viewportSize.width);
                    final renderWidth = min(
                      _maxRenderWidth,
                      pageRects.first.width *
                          MediaQuery.devicePixelRatioOf(context) *
                          _renderOversampling,
                    );
                    return Listener(
                      onPointerDown: _onViewerPointerDown,
                      onPointerUp: _onViewerPointerEnd,
                      onPointerCancel: _onViewerPointerEnd,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        constrained: false,
                        minScale: _minScale,
                        maxScale: _maxScale,
                        panEnabled: tool == PdfAnnotationTool.pan,
                        child: SizedBox(
                          width: viewportSize.width,
                          height: pageRects.last.bottom + _pageMargin,
                          child: ListenableBuilder(
                            listenable: _transformationController,
                            builder: (context, _) {
                              final visibleRect = _visibleSceneRect(
                                viewportSize,
                              );
                              return Stack(
                                children: [
                                  for (
                                    var index = 0;
                                    index < pageRects.length;
                                    index++
                                  )
                                    if (pageRects[index].overlaps(visibleRect))
                                      Positioned.fromRect(
                                        key: ValueKey(index),
                                        rect: pageRects[index],
                                        child: _PdfAnnotationPageWidget(
                                          tool: tool,
                                          annotations: _annotationController
                                              .annotationsOfPage(index),
                                          activeStroke: _annotationController
                                              .activeStrokeOfPage(index),
                                          progressColor: widget.primaryColor,
                                          loadImage: (isStillNeeded) =>
                                              _loadPageImage(
                                                pageIndex: index,
                                                renderWidth: renderWidth,
                                                isStillNeeded: isStillNeeded,
                                              ),
                                          onPointerDown: (event) =>
                                              _onPagePointerDown(
                                                index,
                                                pageRects[index].size,
                                                event,
                                              ),
                                          onPointerMove: (event) =>
                                              _onPagePointerMove(
                                                index,
                                                pageRects[index].size,
                                                event,
                                              ),
                                          onPointerUp: _onPagePointerUp,
                                          onPointerCancel: _onPagePointerCancel,
                                          onTextTap: (position) => _addTextAt(
                                            index,
                                            pageRects[index].size,
                                            position,
                                          ),
                                        ),
                                      ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (_isSaving)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: Colors.black38,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: widget.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: isReady
              ? _PdfAnnotationToolbarWidget(
                  texts: widget.texts,
                  primaryColor: widget.primaryColor,
                  selectedTool: tool,
                  selectedColor: _annotationController.toolColor,
                  selectedStrokeSizeIndex:
                      _annotationController.strokeSizeIndex,
                  showStrokeSizes: _annotationController.isDrawingTool,
                  canUndo: _annotationController.canUndo,
                  canRedo: _annotationController.canRedo,
                  isEnabled: !_isSaving,
                  onToolSelected: _annotationController.selectTool,
                  onColorSelected: _annotationController.selectToolColor,
                  onStrokeSizeSelected: _annotationController.selectStrokeSize,
                  onUndo: _annotationController.undo,
                  onRedo: _annotationController.redo,
                )
              : null,
        ),
      );
    },
  );
}
