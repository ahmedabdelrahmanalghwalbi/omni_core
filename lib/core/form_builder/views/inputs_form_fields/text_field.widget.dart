part of '../../../../omni_core.dart';

class TextFieldWidget extends StatelessWidget {
  final TextFormFieldModel? textFormFieldModel;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final double fieldHeight;
  final double fieldIconSize;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool isReadOnly;
  final bool isEditMode;
  final TextStyle? fieldHintStyle;
  final EdgeInsetsGeometry? fieldContentPadding;
  final Color primaryColor;
  final bool? showValidationMessage;
  final void Function(String)? onChanged;
  const TextFieldWidget({
    super.key,
    required this.textFormFieldModel,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldHeight,
    required this.fieldIconSize,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    required this.spacing,
    required this.innerSpacing,
    required this.primaryColor,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.fieldHintStyle,
    this.fieldContentPadding,
    this.showValidationMessage,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder fieldBorder = OutlineInputBorder(
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
          if (textFormFieldModel?.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: textFormFieldModel!.title!,
              isRequired: textFormFieldModel?.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              initialValue: isReadOnly
                  ? textFormFieldModel?.submittedValue
                  : (textFormFieldModel?.submittedValue ??
                        textFormFieldModel?.value?.toString()),
              style: fieldTextStyle,
              readOnly: isReadOnly,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: textFormFieldModel?.placeholder,
                filled: true,
                fillColor: fieldFillColor,
                contentPadding: fieldContentPadding,
                isDense: false,
                border: fieldBorder,
                enabledBorder: fieldBorder,
                focusedBorder: fieldBorder,
                disabledBorder: fieldBorder,
                hintStyle: fieldHintStyle,
              ),
            ),
          ),
          FieldValidationMessageWidget(
            requiredValidation: textFormFieldModel?.required,
            showValidationMessage: showValidationMessage,
          ),
        ],
      ),
    );
  }
}
