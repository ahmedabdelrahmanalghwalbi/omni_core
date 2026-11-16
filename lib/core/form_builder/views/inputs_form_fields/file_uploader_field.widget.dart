part of '../../../../omni_core.dart';

class FileUploaderFieldWidget extends StatefulWidget {
  final FileUploaderFormFieldModel fileUploaderFormFieldModel;
  final bool isReadOnly;
  final bool isEditMode;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle fieldLabelTextStyle;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldIconSize;
  final double fieldHeight;
  final TextStyle fieldHintStyle;
  final Color primaryColor;
  final bool? showValidationMessage;

  /// Lets the user annotate a picked or already attached PDF (draw,
  /// highlight, add text) and upload the annotated copy instead.
  final bool enablePdfAnnotation;
  final PdfAnnotationTexts pdfAnnotationTexts;
  final void Function(File?) onChanged;

  const FileUploaderFieldWidget({
    super.key,
    required this.fileUploaderFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.fieldBorderColor,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldRadius,
    required this.fieldIconSize,
    required this.fieldHintStyle,
    required this.fieldHeight,
    required this.primaryColor,
    required this.onChanged,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.showValidationMessage,
    this.enablePdfAnnotation = false,
    this.pdfAnnotationTexts = const PdfAnnotationTexts(),
  });

  @override
  State<FileUploaderFieldWidget> createState() =>
      _FileUploaderFieldWidgetState();
}

class _FileUploaderFieldWidgetState extends State<FileUploaderFieldWidget> {
  static const String _pdfExtension = '.pdf';
  static const double _annotationProgressSize = 20.0;
  static const double _annotationProgressStrokeWidth = 2.0;

  String? _filePath;
  bool _isPreparingAnnotation = false;

  @override
  void initState() {
    super.initState();
    if (widget.isReadOnly) return;
    final model = widget.fileUploaderFormFieldModel;
    // Prefer the picked/restored file (e.g. a draft restore sets `value`),
    // falling back to any pre-existing file path on the model.
    if (model.value != null) {
      _filePath = model.value!.path;
    } else if (model.files?.isNotEmpty ?? false) {
      _filePath = model.files!.first;
    }
  }

  Future<void> _pickFile() async {
    if (widget.isReadOnly) return;

    final pickedFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'docx',
        'doc',
        'xlsx',
        'xls',
        'ppt',
        'pptx',
        'jpg',
        'jpeg',
        'png',
        'txt',
        'csv',
      ],
    );

    final pickedFilePath = pickedFile?.path;
    if (pickedFilePath != null) {
      setState(() {
        _filePath = pickedFilePath;
        widget.fileUploaderFormFieldModel.files = [pickedFilePath];
      });
    }
    widget.onChanged(
      (_filePath?.isNotEmpty ?? false) ? File(_filePath!) : null,
    );
  }

  bool _isPdf(String? pathOrUrl) {
    if (pathOrUrl == null) return false;
    final withoutQueryOrFragment = pathOrUrl.split(RegExp('[?#]')).first;
    return withoutQueryOrFragment.toLowerCase().endsWith(_pdfExtension);
  }

  Future<void> _annotatePickedFile() async {
    final filePath = _filePath;
    if (filePath == null || filePath.isEmpty) return;
    await _openPdfAnnotationEditor(filePath: filePath);
  }

  Future<void> _annotateSubmittedFile() async {
    final fileUri = Uri.tryParse(
      widget.fileUploaderFormFieldModel.submittedValue ?? '',
    );
    if (_isPreparingAnnotation || fileUri == null) return;
    if (!fileUri.isScheme('https') && !fileUri.isScheme('http')) {
      ToastUtils.showError(widget.pdfAnnotationTexts.loadFailedMessage);
      return;
    }

    setState(() => _isPreparingAnnotation = true);
    try {
      final downloadedFile = await AppImageCacheManagerUtils.instance
          .getSingleFile(fileUri.toString());
      if (!mounted) return;
      await _openPdfAnnotationEditor(
        filePath: downloadedFile.path,
        outputFileName: fileUri.pathSegments.last,
      );
    } catch (e, stackTrace) {
      PackageLogger.error(
        'Error downloading PDF for annotation',
        error: e,
        stackTrace: stackTrace,
      );
      ToastUtils.showError(widget.pdfAnnotationTexts.loadFailedMessage);
    } finally {
      if (mounted) setState(() => _isPreparingAnnotation = false);
    }
  }

  Future<void> _openPdfAnnotationEditor({
    required String filePath,
    String? outputFileName,
  }) async {
    final annotatedFile = await AppRouter.navigateTo(
      () => PdfAnnotationEditorView(
        filePath: filePath,
        outputFileName: outputFileName,
        primaryColor: widget.primaryColor,
        texts: widget.pdfAnnotationTexts,
      ),
    );
    if (annotatedFile is! File || !mounted) return;

    setState(() {
      _filePath = annotatedFile.path;
      widget.fileUploaderFormFieldModel.files = [annotatedFile.path];
    });
    widget.onChanged(annotatedFile);
  }

  Future<void> _viewFile({required String fileUrl}) async {
    try {
      // 1️⃣ Validate input
      if (fileUrl.isEmpty) {
        ToastUtils.showWarning('The file link is missing or invalid.');
        return;
      }

      final Uri uri = Uri.parse(fileUrl);

      // 2️⃣ Check if the URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        ToastUtils.showError('This file link cannot be opened on your device.');
        return;
      }

      // 3️⃣ Try to open file in external app or browser
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // 4️⃣ Handle unsuccessful launch
      if (!launched) {
        ToastUtils.showError('Couldn’t open the file. Please try again.');
      }
    } catch (e, stackTrace) {
      // 5️⃣ Handle unexpected errors gracefully
      PackageLogger.error(
        'Error opening file',
        error: e,
        stackTrace: stackTrace,
      );
      ToastUtils.showError('Something went wrong while opening the file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReadOnly) {
      return LabelFieldWidget(
        lableFormFieldModel: LabelFormFieldModel(
          data: widget.fileUploaderFormFieldModel.submittedValue
              ?.split('/')
              .last,
          css: widget.fileUploaderFormFieldModel.css,
          title: widget.fileUploaderFormFieldModel.title,
          placeholder: widget.fileUploaderFormFieldModel.placeholder,
          key: widget.fileUploaderFormFieldModel.key,
          required: widget.fileUploaderFormFieldModel.required,
        ),
        spacing: widget.spacing,
        innerSpacing: widget.innerSpacing,
        fieldLabelTextStyle: widget.fieldLabelTextStyle,
        primaryColor: widget.primaryColor,
        onLabelFieldTab:
            (widget.fileUploaderFormFieldModel.submittedValue?.isNotEmpty ??
                false)
            ? () async => _viewFile(
                fileUrl: widget.fileUploaderFormFieldModel.submittedValue!,
              )
            : null,
      );
    }
    final bool hasFile = _filePath?.isNotEmpty ?? false;
    final fileName = hasFile ? _filePath!.split('/').last : 'file';
    final canAnnotatePickedFile =
        widget.enablePdfAnnotation && hasFile && _isPdf(_filePath);
    final canAnnotateSubmittedFile =
        widget.enablePdfAnnotation &&
        widget.isEditMode &&
        !hasFile &&
        _isPdf(widget.fileUploaderFormFieldModel.submittedValue);
    return Container(
      margin: EdgeInsets.only(bottom: widget.spacing),
      padding: EdgeInsets.symmetric(horizontal: widget.spacing),
      child: Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        spacing: widget.innerSpacing,
        children: [
          if (widget.fileUploaderFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: widget.fileUploaderFormFieldModel.title!,
              isRequired:
                  widget.fileUploaderFormFieldModel.required?.value == true,
              style: widget.fieldLabelTextStyle,
            ),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              height: hasFile ? null : widget.fieldHeight,
              padding: EdgeInsets.symmetric(
                horizontal: widget.spacing,
                vertical: widget.innerSpacing,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.fieldBorderColor,
                  width: widget.fieldBorderWidth,
                ),
                borderRadius: BorderRadius.circular(widget.fieldRadius),
                color: widget.fieldFillColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: widget.innerSpacing,
                children: [
                  SvgPicture.asset(
                    PackageAssetsConstants.formUpload,
                    package: 'omni_core',
                    width: widget.fieldIconSize,
                    height: widget.fieldIconSize,
                  ),
                  Flexible(child: Text(fileName, style: widget.fieldHintStyle)),
                  if (canAnnotatePickedFile)
                    IconButton(
                      tooltip: widget.pdfAnnotationTexts.annotateAction,
                      onPressed: _annotatePickedFile,
                      color: widget.primaryColor,
                      icon: const Icon(Icons.draw_outlined),
                    ),
                ],
              ),
            ),
          ),
          if (widget.isEditMode && !hasFile)
            LabelFieldWidget(
              lableFormFieldModel: LabelFormFieldModel(
                data: widget.fileUploaderFormFieldModel.submittedValue
                    ?.split('/')
                    .last,
                css: widget.fileUploaderFormFieldModel.css,
                title: widget.fileUploaderFormFieldModel.title,
                placeholder: widget.fileUploaderFormFieldModel.placeholder,
                key: widget.fileUploaderFormFieldModel.key,
                required: widget.fileUploaderFormFieldModel.required,
              ),
              spacing: 0.0,
              innerSpacing: widget.innerSpacing,
              fieldLabelTextStyle: widget.fieldLabelTextStyle,
              primaryColor: widget.primaryColor,
              onLabelFieldTab:
                  (widget
                          .fileUploaderFormFieldModel
                          .submittedValue
                          ?.isNotEmpty ??
                      false)
                  ? () async => _viewFile(
                      fileUrl:
                          widget.fileUploaderFormFieldModel.submittedValue!,
                    )
                  : null,
            ),
          if (canAnnotateSubmittedFile)
            TextButton.icon(
              onPressed: _isPreparingAnnotation ? null : _annotateSubmittedFile,
              style: TextButton.styleFrom(foregroundColor: widget.primaryColor),
              icon: _isPreparingAnnotation
                  ? SizedBox.square(
                      dimension: _annotationProgressSize,
                      child: CircularProgressIndicator(
                        strokeWidth: _annotationProgressStrokeWidth,
                        color: widget.primaryColor,
                      ),
                    )
                  : const Icon(Icons.draw_outlined),
              label: Text(widget.pdfAnnotationTexts.annotateAction),
            ),
          FieldValidationMessageWidget(
            requiredValidation: widget.fileUploaderFormFieldModel.required,
            showValidationMessage: widget.showValidationMessage,
          ),
        ],
      ),
    );
  }
}
