part of '../../../../omni_core.dart';

class DropdownFieldWidget extends StatelessWidget {
  final DropdownFormFieldModel dropdownFormFieldModel;
  final double height;
  final bool isReadOnly;
  final bool isEditMode;
  final double spacing;
  final double innerSpacing;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final TextStyle? fieldHintStyle;
  final EdgeInsetsGeometry? fieldContentPadding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? opacity;
  final bool? showPrefixLoading;
  final Color primaryColor;
  final double fieldIconSize;
  final bool? showValidationMessage;
  final void Function(Map<String, dynamic>)? onChanged;

  const DropdownFieldWidget({
    super.key,
    required this.spacing,
    required this.fieldIconSize,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    required this.height,
    required this.dropdownFormFieldModel,
    required this.primaryColor,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.showValidationMessage,
    this.onChanged,
    this.opacity,
    this.showPrefixLoading,
    this.fieldHintStyle,
    this.fieldContentPadding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return TextFieldWidget(
        textFormFieldModel: TextFormFieldModel(
          css: dropdownFormFieldModel.css,
          key: dropdownFormFieldModel.key,
          placeholder: dropdownFormFieldModel.placeholder,
          required: dropdownFormFieldModel.required,
          submittedValue: dropdownFormFieldModel.submittedValue,
          title: dropdownFormFieldModel.title,
        ),
        fieldBorderColor: fieldBorderColor,
        fieldBorderWidth: fieldBorderWidth,
        fieldFillColor: fieldFillColor,
        fieldHeight: height,
        fieldIconSize: fieldIconSize,
        fieldLabelTextStyle: fieldLabelTextStyle,
        fieldRadius: fieldRadius,
        fieldTextStyle: fieldTextStyle,
        spacing: spacing,
        innerSpacing: innerSpacing,
        isReadOnly: true,
        primaryColor: primaryColor,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        fieldHintStyle: fieldHintStyle,
        fieldContentPadding: fieldContentPadding,
        showValidationMessage: false,
        onChanged: (_) {},
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      margin: EdgeInsets.only(bottom: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (dropdownFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: dropdownFormFieldModel.title!,
              isRequired: dropdownFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          Opacity(
            opacity: opacity ?? 1.0,
            child: SizedBox(
              height: height,
              child: CustomDropdown.search(
                searchHintText: dropdownFormFieldModel.placeholder,
                contentPadding: EdgeInsets.symmetric(horizontal: innerSpacing),
                borderRadius: BorderRadius.circular(fieldRadius),
                fillColor: fieldFillColor,
                borderSide: BorderSide(
                  color: fieldBorderColor,
                  width: fieldBorderWidth,
                ),
                nameKey: 'label',
                nameMapKey: 'ar',
                selectedValue: dropdownFormFieldModel.value,
                hintText: dropdownFormFieldModel.placeholder,
                items: dropdownFormFieldModel.data,
                onChanged: onChanged,
                hintStyle: fieldHintStyle,
                labelStyle: fieldLabelTextStyle,
                listItemStyle: fieldTextStyle,
                selectedStyle: fieldTextStyle,
                fieldSuffixIcon: showPrefixLoading == true
                    ? Transform.scale(
                        scale: 0.3,
                        child: const CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(0xff9E9E9E)),
                          strokeWidth: 6,
                        ),
                      )
                    : const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Color(0xff9E9E9E),
                        size: 20.0,
                      ),
              ),
            ),
          ),

          FieldValidationMessageWidget(
            requiredValidation: dropdownFormFieldModel.required,
            showValidationMessage: showValidationMessage,
          ),
        ],
      ),
    );
  }
}
