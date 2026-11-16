part of '../../../../omni_core.dart';

class ToggleFieldWidget extends StatelessWidget {
  final ToggleFormFieldModel toggleFormFieldModel;
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
  final void Function(bool) onChanged;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Color primaryColor;
  final bool? showValidationMessage;

  const ToggleFieldWidget({
    super.key,
    required this.toggleFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    required this.primaryColor,
    required this.onChanged,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.fieldHintStyle,
    this.fieldContentPadding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.showValidationMessage,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: spacing),
    padding: EdgeInsets.symmetric(horizontal: spacing),
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
            if (toggleFormFieldModel.title?.isNotEmpty ?? false)
              FieldTitleWithRequiredWidget(
                title: toggleFormFieldModel.title!,
                isRequired: toggleFormFieldModel.required?.value == true,
                style: fieldLabelTextStyle,
              ),
            Transform.scale(
              scale: 0.7,
              child: Switch(
                value:
                    (isReadOnly
                        ? toggleFormFieldModel.submittedValue
                        : (toggleFormFieldModel.submittedValue ??
                              toggleFormFieldModel.value)) ??
                    false,
                onChanged: isReadOnly ? null : onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeTrackColor: primaryColor,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        FieldValidationMessageWidget(
          requiredValidation: toggleFormFieldModel.required,
          showValidationMessage: showValidationMessage,
        ),
      ],
    ),
  );
}
