part of '../../../../omni_core.dart';

class TakePhotoFieldWidget extends StatefulWidget {
  final TakePhotoFormFieldModel takePhotoFieldModel;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle fieldLabelTextStyle;
  final bool isReadOnly;
  final bool isEditMode;
  final ImageShape imageShape;
  final double fieldSize;
  final double fieldRadius;
  final double fieldIconSize;
  final Color primaryColor;
  final VoidCallback? onSelectOrPickPhotoFailed;
  final VoidCallback? onSelectOrPickPhotoSizeValidationFailed;
  final bool? showValidationMessage;
  final String selectOptionText;
  final String takePhotoText;
  final String chooseFromGalleryText;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final void Function(File?) onChanged;

  const TakePhotoFieldWidget({
    super.key,
    required this.takePhotoFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.fieldSize,
    required this.fieldRadius,
    required this.fieldIconSize,
    required this.primaryColor,
    required this.onSelectOrPickPhotoFailed,
    required this.onSelectOrPickPhotoSizeValidationFailed,
    required this.selectOptionText,
    required this.takePhotoText,
    required this.chooseFromGalleryText,
    required this.onChanged,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.imageShape = ImageShape.rectangle,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.showValidationMessage,
  });

  @override
  State<TakePhotoFieldWidget> createState() => _TakePhotoFieldWidgetState();
}

class _TakePhotoFieldWidgetState extends State<TakePhotoFieldWidget> {
  String? _imagePath;
  final int defaultQuality = 85;
  final double defaultMaxWidth = 1920.0;
  final double defaultMaxHeight = 1080.0;
  final int maxSizeInMB = 10;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.takePhotoFieldModel.value?.path;
  }

  bool _imageSizeValidation(File file, {int maxSizeInMigaBytes = 10}) {
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeInMB > maxSizeInMigaBytes) {
      widget.onSelectOrPickPhotoSizeValidationFailed?.call();
      PackageLogger.error('Image size should not exceed 10MB');
      return false;
    }
    return true;
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: defaultQuality,
        maxHeight: defaultMaxHeight,
        maxWidth: defaultMaxWidth,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final isValid = _imageSizeValidation(
          file,
          maxSizeInMigaBytes: maxSizeInMB,
        );
        if (!isValid) return;
        setState(() {
          _imagePath = pickedImage.path;
          if (_imagePath?.isNotEmpty ?? false) {
            widget.takePhotoFieldModel.value = File(_imagePath!);
          }
        });
        widget.onChanged.call(file);
      }
    } catch (e, s) {
      widget.onSelectOrPickPhotoFailed?.call();
      PackageLogger.error('Error taking photo', error: e, stackTrace: s);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: defaultQuality,
        maxHeight: defaultMaxHeight,
        maxWidth: defaultMaxWidth,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final isValid = _imageSizeValidation(
          file,
          maxSizeInMigaBytes: maxSizeInMB,
        );
        if (!isValid) return;
        setState(() {
          _imagePath = pickedImage.path;
          if (_imagePath?.isNotEmpty ?? false) {
            widget.takePhotoFieldModel.value = File(_imagePath!);
          }
        });
        widget.onChanged.call(file);
      }
    } catch (e, s) {
      widget.onSelectOrPickPhotoFailed?.call();
      PackageLogger.error('Error picking photo', error: e, stackTrace: s);
    }
  }

  void _showPickerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.all(widget.spacing),
        title: Text(widget.selectOptionText),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(widget.takePhotoText),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(widget.chooseFromGalleryText),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageSelection() {
    if (widget.takePhotoFieldModel.showPickingOptions == true) {
      _showPickerDialog(context);
    } else {
      _takePhoto();
    }
  }

  void _openPreview(BuildContext context) {
    if (_imagePath == null) return;

    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: PhotoView(
          imageProvider: FileImage(File(_imagePath!)),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _imagePath != null ? File(_imagePath!) : null;

    final imageWidget = image != null
        ? GestureDetector(
            onTap: () => _openPreview(context),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: widget.fieldSize,
            ),
          )
        : Container(
            width: double.infinity,
            height: widget.fieldSize,
            color: Colors.grey.shade200,
            child: Icon(
              Icons.camera_alt,
              size: widget.fieldIconSize,
              color: Colors.grey,
            ),
          );
    // If read-only mode: return ImageFieldWidget instead
    if (widget.isReadOnly) {
      return ImageFieldWidget(
        imageFormFieldModel: ImageFormFieldModel(
          data: widget.takePhotoFieldModel.submittedValue,
          title: widget.takePhotoFieldModel.title,
          required: widget.takePhotoFieldModel.required,
          css: widget.takePhotoFieldModel.css,
          placeholder: widget.takePhotoFieldModel.placeholder,
        ),
        spacing: widget.spacing,
        innerSpacing: widget.innerSpacing,
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        fieldLabelTextStyle: widget.fieldLabelTextStyle,
        imageShape: widget.imageShape,
        imageFieldSize: widget.fieldSize,
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
          if (widget.takePhotoFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: widget.takePhotoFieldModel.title!,
              isRequired: widget.takePhotoFieldModel.required?.value == true,
              style: widget.fieldLabelTextStyle,
            ),

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              (widget.imageShape == ImageShape.circle)
                  ? ClipOval(
                      child: SizedBox(
                        width: widget.fieldSize,
                        height: widget.fieldSize,
                        child: imageWidget,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(widget.fieldRadius),
                      child: imageWidget,
                    ),
              Positioned(
                bottom: widget.innerSpacing,
                right: widget.innerSpacing,
                child: GestureDetector(
                  // onTap: _takePhoto,
                  onTap: _handleImageSelection,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.primaryColor,
                    ),
                    padding: EdgeInsets.all(widget.innerSpacing),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: widget.fieldIconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
          FieldValidationMessageWidget(
            requiredValidation: widget.takePhotoFieldModel.required,
            showValidationMessage: widget.showValidationMessage,
          ),
        ],
      ),
    );
  }
}
