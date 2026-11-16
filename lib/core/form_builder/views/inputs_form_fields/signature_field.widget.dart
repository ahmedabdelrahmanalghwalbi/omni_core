part of '../../../../omni_core.dart';

class SignatureFieldWidget extends StatefulWidget {
  final SignatureFormFieldModel signatureFormFieldModel;
  final double fieldRadius;
  final Color fieldBorderColor;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final double height;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle fieldLabelTextStyle;
  final double fieldIconSize;
  final bool isReadOnly;
  final bool isEditMode;
  final double readOnlySignatureImageSize;
  final Color primaryColor;
  final String clearSignatureButtonText;
  final bool? showValidationMessage;
  final void Function(File?) onChanged;

  const SignatureFieldWidget({
    super.key,
    required this.signatureFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.fieldRadius,
    required this.fieldBorderColor,
    required this.fieldBorderWidth,
    required this.height,
    required this.fieldFillColor,
    required this.fieldIconSize,
    required this.primaryColor,
    required this.onChanged,
    required this.clearSignatureButtonText,
    required this.readOnlySignatureImageSize,
    this.showValidationMessage,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.isReadOnly = false,
    this.isEditMode = false,
  });

  @override
  State<SignatureFieldWidget> createState() => _SignatureFieldWidgetState();
}

class _SignatureFieldWidgetState extends State<SignatureFieldWidget> {
  final GlobalKey<SfSignaturePadState> _signatureKey = GlobalKey();

  /// The last captured signature image. Seeded from the field value so a
  /// pre-filled or draft-restored signature is shown instead of a blank pad.
  File? _capturedSignature;

  @override
  void initState() {
    super.initState();
    final existing = widget.signatureFormFieldModel.value;
    if (existing != null && existing.existsSync()) {
      _capturedSignature = existing;
    }
  }

  Future<void> _getSignature() async {
    try {
      final image = await _signatureKey.currentState?.toImage();
      if (image == null) {
        widget.onChanged.call(null);
        return;
      }

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData?.buffer.asUint8List();

      if (buffer == null) {
        widget.onChanged.call(null);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      // Do not swap the live pad for an image here: onDrawEnd fires after every
      // stroke, so replacing the pad would block multi-stroke signing. The pad
      // stays interactive; the captured file flows out via onChanged. The image
      // preview is only used for a pre-filled / draft-restored value (initState).
      widget.onChanged.call(file);
    } catch (e, s) {
      PackageLogger.error('Error capturing signature', error: e, stackTrace: s);
      widget.onChanged.call(null);
    }
  }

  void _clearSignature() {
    _signatureKey.currentState?.clear();
    setState(() => _capturedSignature = null);
    widget.onChanged.call(null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReadOnly || widget.isEditMode) {
      return ImageFieldWidget(
        imageFormFieldModel: ImageFormFieldModel(
          data: widget.signatureFormFieldModel.submittedValue,
          title: widget.signatureFormFieldModel.title,
          required: widget.signatureFormFieldModel.required,
          css: widget.signatureFormFieldModel.css,
          placeholder: widget.signatureFormFieldModel.placeholder,
        ),
        spacing: widget.spacing,
        innerSpacing: widget.innerSpacing,
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        fieldLabelTextStyle: widget.fieldLabelTextStyle,
        imageShape: ImageShape.rectangle,
        imageFieldSize: widget.readOnlySignatureImageSize,
        fieldRadius: widget.fieldRadius,
        primaryColor: widget.primaryColor,
        fieldBorderColor: widget.fieldBorderColor,
        fieldBorderWidth: widget.fieldBorderWidth,
      );
    }
    return Container(
      margin: EdgeInsets.only(bottom: widget.spacing),
      padding: EdgeInsets.symmetric(horizontal: widget.spacing),
      child: Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        spacing: widget.innerSpacing,
        children: [
          if (widget.signatureFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: widget.signatureFormFieldModel.title!,
              isRequired:
                  widget.signatureFormFieldModel.required?.value == true,
              style: widget.fieldLabelTextStyle,
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.fieldRadius),
                  border: Border.all(
                    color: widget.fieldBorderColor,
                    width: widget.fieldBorderWidth,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.fieldRadius),
                  child: _capturedSignature != null
                      ? Image.file(
                          _capturedSignature!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: widget.height,
                        )
                      : SfSignaturePad(
                          key: _signatureKey,
                          minimumStrokeWidth: 1,
                          maximumStrokeWidth: 3,
                          strokeColor: widget.primaryColor,
                          backgroundColor: widget.fieldFillColor,
                          onDrawEnd: () {
                            if (!widget.isReadOnly) {
                              _getSignature();
                            }
                          },
                        ),
                ),
              ),
              if (!widget.isReadOnly)
                TextButton.icon(
                  onPressed: _clearSignature,
                  icon: Icon(
                    Icons.clear,
                    size: widget.fieldIconSize,
                    color: widget.primaryColor,
                  ),
                  label: Text(
                    widget.clearSignatureButtonText,
                    style: TextStyle(color: widget.primaryColor),
                  ),
                ),
            ],
          ),
          FieldValidationMessageWidget(
            requiredValidation: widget.signatureFormFieldModel.required,
            showValidationMessage: widget.showValidationMessage,
          ),
        ],
      ),
    );
  }
}
