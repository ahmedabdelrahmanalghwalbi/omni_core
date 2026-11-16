part of '../../../../omni_core.dart';

class CheckBoxFieldWidget extends StatelessWidget {
  final CheckboxFormFieldModel checkboxFormFieldModel;
  final bool isReadOnly;
  final bool isEditMode;
  final double spacing;
  final double innerSpacing;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final TextStyle fieldLabelTextStyle;
  final void Function(bool)? onChanged;
  final double fieldIconSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool? showValidationMessage;
  final Color primaryColor;

  const CheckBoxFieldWidget({
    super.key,
    required this.checkboxFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldLabelTextStyle,
    required this.fieldIconSize,
    required this.primaryColor,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.showValidationMessage,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (checkboxFormFieldModel.title?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    final isChecked =
        (isReadOnly
            ? checkboxFormFieldModel.submittedValue
            : (checkboxFormFieldModel.submittedValue ??
                  checkboxFormFieldModel.value)) ??
        false;
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: GestureDetector(
        onTap: isReadOnly ? null : () => onChanged?.call(!isChecked),
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          spacing: innerSpacing,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: innerSpacing,
              children: [
                Container(
                  width: fieldIconSize,
                  height: fieldIconSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(fieldRadius),
                    border: Border.all(
                      color: isChecked ? primaryColor : fieldBorderColor,
                      width: fieldBorderWidth,
                    ),
                    color: isChecked ? primaryColor : Colors.transparent,
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 16.0, color: Colors.white)
                      : null,
                ),
                FieldTitleWithRequiredWidget(
                  title: checkboxFormFieldModel.title!,
                  isRequired: checkboxFormFieldModel.required?.value == true,
                  style: fieldLabelTextStyle,
                ),
              ],
            ),
            FieldValidationMessageWidget(
              requiredValidation: checkboxFormFieldModel.required,
              showValidationMessage: showValidationMessage,
            ),
          ],
        ),
      ),
    );
  }
}
