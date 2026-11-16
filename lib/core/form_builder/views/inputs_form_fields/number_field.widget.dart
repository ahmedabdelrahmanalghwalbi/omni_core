part of '../../../../omni_core.dart';

class NumberFieldWidget extends StatelessWidget {
  final NumberFormFieldModel numberFormFieldModel;
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

  const NumberFieldWidget({
    super.key,
    required this.numberFormFieldModel,
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
          if (numberFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: numberFormFieldModel.title!,
              isRequired: numberFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          SizedBox(
            height: fieldHeight,
            child: TextFormField(
              initialValue: isReadOnly
                  ? numberFormFieldModel.submittedValue?.toString()
                  : (numberFormFieldModel.submittedValue?.toString() ??
                        numberFormFieldModel.value?.toString()),
              style: fieldTextStyle,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const [_DecimalTextInputFormatter()],
              readOnly: isReadOnly,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: numberFormFieldModel.placeholder,
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
            requiredValidation: numberFormFieldModel.required,
            showValidationMessage: showValidationMessage,
          ),
        ],
      ),
    );
  }
}

// Allows an optional single decimal point so the field accepts both integers
// and decimals (num), rejecting any edit that would produce a malformed number.
class _DecimalTextInputFormatter extends TextInputFormatter {
  const _DecimalTextInputFormatter();

  static final RegExp _decimalPattern = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _decimalPattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
