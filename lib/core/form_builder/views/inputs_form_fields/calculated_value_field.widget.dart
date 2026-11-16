part of '../../../../omni_core.dart';

/// Renders a [DerivedValueFormFieldModel] or [ComputedValueFormFieldModel]:
/// the value the engine resolved, shown read-only.
///
/// The field is never editable, so it takes no `onChanged`; a blank value means
/// the sources it reads are still incomplete.
class CalculatedValueFieldWidget extends StatelessWidget {
  final String? title;
  final String displayValue;
  final bool isRequired;
  final String? placeholder;
  final double spacing;
  final double innerSpacing;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final double fieldHeight;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final TextStyle? fieldHintStyle;
  final EdgeInsetsGeometry? fieldContentPadding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const CalculatedValueFieldWidget({
    super.key,
    required this.displayValue,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldHeight,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    this.title,
    this.isRequired = false,
    this.placeholder,
    this.fieldHintStyle,
    this.fieldContentPadding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: spacing),
    margin: EdgeInsets.only(bottom: spacing),
    child: Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: innerSpacing,
      children: [
        if (title?.isNotEmpty ?? false)
          FieldTitleWithRequiredWidget(
            title: title!,
            isRequired: isRequired,
            style: fieldLabelTextStyle,
          ),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: fieldHeight),
          alignment: AlignmentDirectional.centerStart,
          padding:
              fieldContentPadding ??
              EdgeInsets.symmetric(horizontal: innerSpacing),
          decoration: BoxDecoration(
            color: fieldFillColor,
            borderRadius: BorderRadius.circular(fieldRadius),
            border: Border.all(
              color: fieldBorderColor,
              width: fieldBorderWidth,
            ),
          ),
          child: Text(
            displayValue.isNotEmpty ? displayValue : (placeholder ?? '—'),
            style: displayValue.isNotEmpty
                ? fieldTextStyle
                : (fieldHintStyle ?? fieldTextStyle),
          ),
        ),
      ],
    ),
  );
}
