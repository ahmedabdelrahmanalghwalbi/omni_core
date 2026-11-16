part of '../../../omni_core.dart';

class _PdfAnnotationToolbarWidget extends StatelessWidget {
  static const double _spacing = 8.0;
  static const double _tapTargetSize = 44.0;
  static const double _swatchSize = 28.0;
  static const double _selectionBorderWidth = 2.0;
  static const List<double> _strokeSizeDotDiameters = [6.0, 12.0, 18.0];

  final PdfAnnotationTexts texts;
  final Color primaryColor;
  final PdfAnnotationTool selectedTool;
  final Color? selectedColor;
  final int selectedStrokeSizeIndex;
  final bool showStrokeSizes;
  final bool canUndo;
  final bool canRedo;
  final bool isEnabled;
  final void Function(PdfAnnotationTool tool) onToolSelected;
  final void Function(Color color) onColorSelected;
  final void Function(int strokeSizeIndex) onStrokeSizeSelected;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const _PdfAnnotationToolbarWidget({
    required this.texts,
    required this.primaryColor,
    required this.selectedTool,
    required this.selectedColor,
    required this.selectedStrokeSizeIndex,
    required this.showStrokeSizes,
    required this.canUndo,
    required this.canRedo,
    required this.isEnabled,
    required this.onToolSelected,
    required this.onColorSelected,
    required this.onStrokeSizeSelected,
    required this.onUndo,
    required this.onRedo,
  });

  String _toolLabel(PdfAnnotationTool tool) => switch (tool) {
    PdfAnnotationTool.pan => texts.panTool,
    PdfAnnotationTool.pen => texts.penTool,
    PdfAnnotationTool.highlighter => texts.highlighterTool,
    PdfAnnotationTool.text => texts.textTool,
    PdfAnnotationTool.eraser => texts.eraserTool,
  };

  IconData _toolIcon(PdfAnnotationTool tool) => switch (tool) {
    PdfAnnotationTool.pan => Icons.pan_tool_outlined,
    PdfAnnotationTool.pen => Icons.edit_outlined,
    PdfAnnotationTool.highlighter => Icons.border_color_outlined,
    PdfAnnotationTool.text => Icons.title,
    PdfAnnotationTool.eraser => Icons.backspace_outlined,
  };

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 8.0,
    child: SafeArea(
      top: false,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedColor != null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: _spacing),
                child: Row(
                  children: [
                    for (final color in PdfAnnotationController.palette)
                      _PdfAnnotationOptionWidget(
                        size: _tapTargetSize,
                        isSelected: color == selectedColor,
                        onTap: () => onColorSelected(color),
                        child: Container(
                          width: _swatchSize,
                          height: _swatchSize,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color == selectedColor
                                  ? primaryColor
                                  : Colors.black26,
                              width: _selectionBorderWidth,
                            ),
                          ),
                          child: color == selectedColor
                              ? Icon(
                                  Icons.check,
                                  size: _swatchSize / 2,
                                  color: color.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      ),
                    if (showStrokeSizes) ...[
                      const SizedBox(width: _spacing),
                      for (
                        var index = 0;
                        index < _strokeSizeDotDiameters.length;
                        index++
                      )
                        _PdfAnnotationOptionWidget(
                          size: _tapTargetSize,
                          semanticLabel: texts.strokeSize,
                          isSelected: index == selectedStrokeSizeIndex,
                          onTap: () => onStrokeSizeSelected(index),
                          child: Container(
                            width: _swatchSize,
                            height: _swatchSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: index == selectedStrokeSizeIndex
                                    ? primaryColor
                                    : Colors.transparent,
                                width: _selectionBorderWidth,
                              ),
                            ),
                            child: Container(
                              width: _strokeSizeDotDiameters[index],
                              height: _strokeSizeDotDiameters[index],
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _spacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final tool in PdfAnnotationTool.values)
                    IconButton(
                      tooltip: _toolLabel(tool),
                      isSelected: tool == selectedTool,
                      onPressed: () => onToolSelected(tool),
                      icon: Icon(_toolIcon(tool)),
                      style: IconButton.styleFrom(
                        foregroundColor: tool == selectedTool
                            ? Colors.white
                            : Colors.black87,
                        backgroundColor: tool == selectedTool
                            ? primaryColor
                            : Colors.transparent,
                      ),
                    ),
                  IconButton(
                    tooltip: texts.undo,
                    onPressed: canUndo ? onUndo : null,
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    tooltip: texts.redo,
                    onPressed: canRedo ? onRedo : null,
                    icon: const Icon(Icons.redo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PdfAnnotationOptionWidget extends StatelessWidget {
  final double size;
  final bool isSelected;
  final String? semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  const _PdfAnnotationOptionWidget({
    required this.size,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: isSelected,
    label: semanticLabel,
    child: InkResponse(
      onTap: onTap,
      radius: size / 2,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    ),
  );
}
