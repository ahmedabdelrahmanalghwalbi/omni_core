part of '../../../../omni_core.dart';

/// Read-only rendering of a multi-selection: the same titled field the editable
/// multi-selects draw, showing the submitted values as chips through
/// [CustomMultiDropdownReadOnlyField] so both modes share one styling source.
class SelectedValuesReadOnlyFieldWidget extends StatelessWidget {
  final List<String> values;
  final String? title;
  final bool isRequired;
  final String? placeholder;
  final double height;
  final double spacing;
  final double innerSpacing;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final TextStyle? fieldHintStyle;
  final Color? chipBackgroundColor;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const SelectedValuesReadOnlyFieldWidget({
    super.key,
    required this.values,
    required this.height,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    this.title,
    this.isRequired = false,
    this.placeholder,
    this.fieldHintStyle,
    this.chipBackgroundColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// The dropdown field reads its chip texts off a map, so the already
  /// resolved display values are handed over under a single key.
  static const String _displayValueKey = 'displayValue';

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
        // Chips wrap onto as many lines as the selection needs, so the field
        // only starts at the shared field height.
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: CustomMultiDropdownReadOnlyField(
            selectedItems: values
                .map((value) => <String, dynamic>{_displayValueKey: value})
                .toList(),
            nameKey: _displayValueKey,
            contentPadding: EdgeInsets.symmetric(horizontal: innerSpacing),
            borderRadius: BorderRadius.circular(fieldRadius),
            fillColor: fieldFillColor,
            borderSide: BorderSide(
              color: fieldBorderColor,
              width: fieldBorderWidth,
            ),
            // A read-only field with nothing submitted stays blank rather than
            // inviting a selection it cannot take.
            hintText: placeholder ?? '',
            hintStyle: fieldHintStyle,
            selectedStyle: fieldTextStyle,
            selectedItemChipBackgroundColor: chipBackgroundColor,
          ),
        ),
      ],
    ),
  );
}
