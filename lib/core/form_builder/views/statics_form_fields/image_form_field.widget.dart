part of '../../../../omni_core.dart';

class ImageFieldWidget extends StatelessWidget {
  final ImageFormFieldModel imageFormFieldModel;
  final ImageShape imageShape;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle fieldLabelTextStyle;
  final double imageFieldSize;
  final double fieldRadius;
  final Color primaryColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;

  const ImageFieldWidget({
    super.key,
    required this.imageFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.imageFieldSize,
    required this.fieldRadius,
    required this.primaryColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.imageShape,
  });

  void _openPreview(BuildContext context) {
    if (!_isValidUrl(imageFormFieldModel.data)) return;
    try {
      if (imageFormFieldModel.data?.isEmpty ?? true) return;
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(
              imageFormFieldModel.data!,
              // Same store the API layer prefetches into, so pre-cached
              // images render offline.
              cacheManager: AppImageCacheManagerUtils.instance,
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      );
    } catch (ex, t) {
      PackageLogger.error('Error opening preview', error: ex, stackTrace: t);
    }
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.isAbsolute &&
            (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')));
  }

  @override
  Widget build(BuildContext context) {
    if (imageFormFieldModel.data == null) return const SizedBox();

    final imageWidget = (!_isValidUrl(imageFormFieldModel.data))
        ? const Icon(Icons.image_not_supported_outlined)
        : CachedNetworkImage(
            imageUrl: imageFormFieldModel.data!,
            // Same store the API layer prefetches into, so pre-cached images
            // render offline.
            cacheManager: AppImageCacheManagerUtils.instance,
            fit: imageFormFieldModel.fit ?? BoxFit.cover,
            height: imageFieldSize,
            width: double.infinity,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator(color: primaryColor)),
            errorWidget: (context, url, error) =>
                const Icon(Icons.image_not_supported_outlined),
          );
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (imageFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: imageFormFieldModel.title!,
              isRequired: imageFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          GestureDetector(
            onTap: () => _openPreview(context),
            child: (imageShape == ImageShape.circle)
                ? ClipOval(
                    child: SizedBox(
                      height: imageFieldSize,
                      width: imageFieldSize,
                      child: imageWidget,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(fieldRadius),
                      border: Border.all(
                        color: fieldBorderColor,
                        width: fieldBorderWidth,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(fieldRadius),
                      child: imageWidget,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
