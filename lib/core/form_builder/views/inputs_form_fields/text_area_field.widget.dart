part of '../../../../omni_core.dart';

class TextAreaFieldWidget extends StatelessWidget {
  final TextAreaFormFieldModel textAreaFormFieldModel;
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
  final int textAreaMinLine;
  final void Function(String)? onChanged;

  const TextAreaFieldWidget({
    super.key,
    required this.textAreaFormFieldModel,
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
    this.textAreaMinLine = 5,
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
          if (textAreaFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: textAreaFormFieldModel.title!,
              isRequired: textAreaFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          TextFormField(
            initialValue: isReadOnly
                ? textAreaFormFieldModel.submittedValue
                : (textAreaFormFieldModel.submittedValue ??
                      textAreaFormFieldModel.value?.toString()),
            style: fieldTextStyle,
            maxLines: null,
            minLines: textAreaMinLine,
            readOnly: isReadOnly,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: textAreaFormFieldModel.placeholder,
              hintStyle: fieldHintStyle,
              filled: true,
              isDense: false,
              fillColor: fieldFillColor,
              contentPadding: fieldContentPadding,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldBorder,
              disabledBorder: fieldBorder,
            ),
          ),
          FieldValidationMessageWidget(
            requiredValidation: textAreaFormFieldModel.required,
            showValidationMessage: showValidationMessage,
          ),
        ],
      ),
    );
  }
}
