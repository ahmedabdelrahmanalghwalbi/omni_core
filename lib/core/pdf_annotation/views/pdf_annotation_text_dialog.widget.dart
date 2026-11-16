part of '../../../omni_core.dart';

/// Asks for the content of a text annotation and pops with it.
class _PdfAnnotationTextDialogWidget extends StatefulWidget {
  final PdfAnnotationTexts texts;
  final Color primaryColor;

  const _PdfAnnotationTextDialogWidget({
    required this.texts,
    required this.primaryColor,
  });

  @override
  State<_PdfAnnotationTextDialogWidget> createState() =>
      _PdfAnnotationTextDialogWidgetState();
}

class _PdfAnnotationTextDialogWidgetState
    extends State<_PdfAnnotationTextDialogWidget> {
  static const int _minLines = 5;
  static const int _maxLines = 8;
  static const int _maxLength = 500;
  static const double _maxDialogWidth = 480.0;
  static const double _dialogRadius = 20.0;
  static const double _fieldRadius = 12.0;
  static const double _padding = 20.0;
  static const double _spacing = 16.0;
  static const double _headerIconBoxSize = 40.0;
  static const double _headerIconSize = 22.0;
  static const double _actionHeight = 48.0;
  static const double _focusedBorderWidth = 1.5;
  static const double _headerTintAlpha = 0.12;
  static const Color _fieldFillColor = Color(0xFFF7F8FA);
  static const Color _fieldBorderColor = Color(0xFFE1E4EA);

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  void _cancel() => Navigator.of(context).pop();

  OutlineInputBorder _fieldBorder(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final actionShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
    );
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_dialogRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxDialogWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _spacing,
            children: [
              Row(
                spacing: _spacing / 2,
                children: [
                  Container(
                    width: _headerIconBoxSize,
                    height: _headerIconBoxSize,
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withValues(
                        alpha: _headerTintAlpha,
                      ),
                      borderRadius: BorderRadius.circular(_fieldRadius),
                    ),
                    child: Icon(
                      Icons.text_fields_rounded,
                      size: _headerIconSize,
                      color: widget.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.texts.textDialogTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: widget.texts.cancel,
                    onPressed: _cancel,
                    color: Colors.black54,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              TextField(
                controller: _textController,
                autofocus: true,
                minLines: _minLines,
                maxLines: _maxLines,
                maxLength: _maxLength,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                textAlignVertical: TextAlignVertical.top,
                cursorColor: widget.primaryColor,
                style: textTheme.bodyLarge?.copyWith(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: widget.texts.textDialogHint,
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: Colors.black38,
                  ),
                  filled: true,
                  fillColor: _fieldFillColor,
                  contentPadding: const EdgeInsets.all(_spacing),
                  border: _fieldBorder(_fieldBorderColor),
                  enabledBorder: _fieldBorder(_fieldBorderColor),
                  focusedBorder: _fieldBorder(
                    widget.primaryColor,
                    width: _focusedBorderWidth,
                  ),
                ),
              ),
              Row(
                spacing: _spacing / 2,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        minimumSize: const Size.fromHeight(_actionHeight),
                        side: const BorderSide(color: _fieldBorderColor),
                        shape: actionShape,
                      ),
                      child: Text(widget.texts.cancel),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _textController,
                      builder: (_, value, _) => FilledButton(
                        onPressed: value.text.trim().isEmpty ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(_actionHeight),
                          shape: actionShape,
                        ),
                        child: Text(widget.texts.textDialogConfirm),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
