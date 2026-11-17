part of '../../../../omni_core.dart';

class MultipleTakePhotosFieldWidget extends StatefulWidget {
  final MultipleTakePhotosFormFieldModel multipleTakePhotosFieldModel;
  final bool readOnly;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle fieldLabelTextStyle;
  final bool isReadOnly;
  final ImageShape imageShape;
  final double fieldSize;
  final double fieldRadius;
  final double fieldIconSize;
  final Color fillColor;
  final Color borderColor;
  final double borderSize;
  final Widget? addImageIcon;
  final Color primaryColor;
  final VoidCallback? onSelectOrPickPhotoFailed;
  final VoidCallback? onSelectOrPickPhotoSizeValidationFailed;
  final bool? showValidationMessage;
  final String selectOptionText;
  final String takePhotoText;
  final String chooseFromGalleryText;
  final bool? canEditPhotos;
  final void Function(List<File>?) onChanged;

  const MultipleTakePhotosFieldWidget({
    super.key,
    required this.multipleTakePhotosFieldModel,
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
    required this.borderColor,
    required this.borderSize,
    required this.fillColor,
    this.canEditPhotos,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.imageShape = ImageShape.rectangle,
    this.readOnly = false,
    this.isReadOnly = false,
    this.addImageIcon,
    this.showValidationMessage,
  });

  @override
  State<MultipleTakePhotosFieldWidget> createState() =>
      _MultipleTakeImagesFieldWidgetState();
}

class _MultipleTakeImagesFieldWidgetState
    extends State<MultipleTakePhotosFieldWidget> {
  List<File> _images = [];
  final int defaultQuality = 85;
  final double defaultMaxWidth = 1920.0;
  final double defaultMaxHeight = 1080.0;
  final int maxSizeInMB = 10;
  final int maxImages = 10;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _images = widget.multipleTakePhotosFieldModel.value ?? [];
  }

  bool _imageSizeValidation(File file, {int maxSizeInMegaBytes = 10}) {
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeInMB > maxSizeInMegaBytes) {
      widget.onSelectOrPickPhotoSizeValidationFailed?.call();
      PackageLogger.error('Image size should not exceed 10MB');
      return false;
    }
    return true;
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isPickingImage = true;
    });

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
          maxSizeInMegaBytes: maxSizeInMB,
        );
        if (!isValid) return;

        setState(() {
          _images.add(file);
          widget.multipleTakePhotosFieldModel.value = _images;
        });
        widget.onChanged.call(_images);
      }
    } catch (e, s) {
      widget.onSelectOrPickPhotoFailed?.call();
      PackageLogger.error('Error taking photo', error: e, stackTrace: s);
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isPickingImage = true;
    });
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
          maxSizeInMegaBytes: maxSizeInMB,
        );
        if (!isValid) return;

        setState(() {
          _images.add(file);
          widget.multipleTakePhotosFieldModel.value = _images;
        });
        widget.onChanged.call(_images);
      }
    } catch (e, s) {
      widget.onSelectOrPickPhotoFailed?.call();
      PackageLogger.error('Error picking photo', error: e, stackTrace: s);
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      widget.multipleTakePhotosFieldModel.value = _images;
    });
    widget.onChanged.call(_images.isEmpty ? null : _images);
  }

  void _showPickerDialog(BuildContext context) {
    // Don't show dialog if already picking an image
    if (_isPickingImage) {
      return;
    }
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
    // Don't handle selection if already picking an image
    if (_isPickingImage) {
      return;
    }
    if (widget.multipleTakePhotosFieldModel.showPickingOptions == true) {
      _showPickerDialog(context);
    } else {
      _takePhoto();
    }
  }

  void _openPreview(BuildContext context, File image) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: PhotoView(
          imageProvider: FileImage(image),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, File image, int index) async {
    final editedBytes = await AppRouter.navigateTo(
      () => ProImageEditor.file(
        image,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            AppRouter.goBack<Uint8List?>(result: bytes);
          },
        ),
      ),
    );

    final parsedEditBytes = AppBaseModel.parseIntList(editedBytes);

    if (parsedEditBytes != null) {
      final String tempPath =
          '${(await getTemporaryDirectory()).path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final File editedFile = await File(tempPath)
          .writeAsBytes(parsedEditBytes);

      setState(() {
        _images[index] = editedFile;
        widget.multipleTakePhotosFieldModel.value = _images;
      });

      widget.onChanged(_images);
    }
  }

  Widget _buildImageContainer(File image, int index) => Stack(
    children: [
      GestureDetector(
        onTap: () {
          if (widget.canEditPhotos == true) {
            _openEditor(context, image, index);
          } else {
            _openPreview(context, image);
          }
        },
        child: Container(
          width: widget.fieldSize,
          height: widget.fieldSize,
          decoration: BoxDecoration(
            borderRadius: widget.imageShape == ImageShape.circle
                ? null
                : BorderRadius.circular(widget.fieldRadius),
            color: Colors.grey.shade200,
          ),
          child: ClipRRect(
            borderRadius: widget.imageShape == ImageShape.circle
                ? BorderRadius.circular(widget.fieldSize / 2)
                : BorderRadius.circular(widget.fieldRadius),
            child: Image.file(
              image,
              fit: BoxFit.cover,
              width: widget.fieldSize,
              height: widget.fieldSize,
            ),
          ),
        ),
      ),
      Positioned(
        top: 6.0,
        right: 6.0,
        child: GestureDetector(
          onTap: () => _removeImage(index),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            padding: EdgeInsets.all(widget.innerSpacing / 2),
            child: Icon(
              Icons.delete,
              color: Colors.white,
              size: widget.fieldIconSize * 0.7,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildAddButton() {
    // Don't show add button if max limit reached
    if (_images.length >= maxImages) {
      return const SizedBox.shrink();
    }

    // Show loading indicator instead of add button when picking image
    if (_isPickingImage) {
      return Container(
        width: widget.fieldSize,
        height: widget.fieldSize,
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderSize,
          ),
          borderRadius: BorderRadius.circular(widget.fieldRadius),
          color: widget.fillColor,
        ),
        child: Center(
          child: SizedBox(
            width: widget.fieldIconSize,
            height: widget.fieldIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _handleImageSelection,
      child: Container(
        width: widget.fieldSize,
        height: widget.fieldSize,
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderSize,
          ),
          borderRadius: BorderRadius.circular(widget.fieldRadius),
          color: widget.fillColor,
        ),
        child:
            widget.addImageIcon ??
            Icon(
              Icons.add,
              size: widget.fieldIconSize,
              color: widget.primaryColor,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If read-only mode: return a row of images
    if (widget.isReadOnly) {
      return Container(
        margin: EdgeInsets.only(bottom: widget.spacing),
        padding: EdgeInsets.symmetric(horizontal: widget.spacing),
        child: Column(
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          spacing: widget.innerSpacing,
          children: [
            if (widget.multipleTakePhotosFieldModel.title?.isNotEmpty ?? false)
              FieldTitleWithRequiredWidget(
                title: widget.multipleTakePhotosFieldModel.title!,
                isRequired:
                    widget.multipleTakePhotosFieldModel.required?.value == true,
                style: widget.fieldLabelTextStyle,
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 items per row
                crossAxisSpacing: widget.innerSpacing,
                mainAxisSpacing: widget.innerSpacing,
                childAspectRatio: 1.0, // Square items
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) => Container(
                width: widget.fieldSize,
                height: widget.fieldSize,
                decoration: BoxDecoration(
                  borderRadius: widget.imageShape == ImageShape.circle
                      ? BorderRadius.circular(widget.fieldSize / 2)
                      : BorderRadius.circular(widget.fieldRadius),
                ),
                child: ClipRRect(
                  borderRadius: widget.imageShape == ImageShape.circle
                      ? BorderRadius.circular(widget.fieldSize / 2)
                      : BorderRadius.circular(widget.fieldRadius),
                  child: Image.file(
                    _images[index],
                    fit: BoxFit.cover,
                    width: widget.fieldSize,
                    height: widget.fieldSize,
                  ),
                ),
              ),
            ),
          ],
        ),
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
          if (widget.multipleTakePhotosFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: widget.multipleTakePhotosFieldModel.title!,
              isRequired:
                  widget.multipleTakePhotosFieldModel.required?.value == true,
              style: widget.fieldLabelTextStyle,
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 items per row
              crossAxisSpacing: widget.innerSpacing,
              mainAxisSpacing: widget.innerSpacing,
              childAspectRatio: 1.0, // Square items
            ),
            itemCount: _images.length + 1, // +1 for the add button
            itemBuilder: (context, index) {
              if (index < _images.length) {
                return _buildImageContainer(_images[index], index);
              } else {
                return _buildAddButton();
              }
            },
          ),
          FieldValidationMessageWidget(
            requiredValidation: widget.multipleTakePhotosFieldModel.required,
            showValidationMessage: widget.showValidationMessage,
          ),
        ],
      ),
    );
  }
}
