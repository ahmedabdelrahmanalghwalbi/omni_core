part of '../../../../omni_core.dart';

class LinkFieldWidget extends StatelessWidget {
  final LinkFormFieldModel linkFormFieldModel;
  final double spacing;
  final double innerSpacing;
  final TextStyle fieldLabelTextStyle;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final double fieldHeight;
  final double fieldIconSize;
  final TextStyle fieldTextStyle;
  final TextStyle? fieldHintStyle;
  final EdgeInsetsGeometry? fieldContentPadding;
  final bool isReadOnly;
  final bool isEditMode;
  final Color primaryColor;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const LinkFieldWidget({
    super.key,
    required this.linkFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldHeight,
    required this.fieldIconSize,
    required this.fieldTextStyle,
    required this.primaryColor,
    required this.isReadOnly,
    required this.isEditMode,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.fieldHintStyle,
    this.fieldContentPadding,
  });

  Future<void> _launchUrl() async {
    if (linkFormFieldModel.data == null) return;

    final uri = Uri.tryParse(linkFormFieldModel.data!);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (linkFormFieldModel.data?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(fieldRadius),
      borderSide: BorderSide(color: fieldBorderColor, width: fieldBorderWidth),
    );
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (linkFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: linkFormFieldModel.title!,
              isRequired: linkFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),

          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              readOnly: true,
              style: fieldTextStyle,
              onTap: isReadOnly ? null : _launchUrl,
              decoration: InputDecoration(
                hintText:
                    linkFormFieldModel.placeholder ?? linkFormFieldModel.data,
                hintStyle: fieldHintStyle,
                filled: true,
                fillColor: fieldFillColor,
                contentPadding: fieldContentPadding ?? const EdgeInsets.all(12),
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                disabledBorder: border,
                suffixIcon: Icon(
                  Icons.touch_app_outlined,
                  size: fieldIconSize,
                  color: const Color(0xffBFBFBF),
                ),
              ),
              controller: TextEditingController(text: linkFormFieldModel.data),
            ),
          ),
        ],
      ),
    );
  }
}
