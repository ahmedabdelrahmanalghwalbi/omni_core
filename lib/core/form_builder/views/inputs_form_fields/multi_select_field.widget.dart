part of '../../../../omni_core.dart';

/// Renders a [MultiSelectFormFieldModel] using [CustomMultiDropdown], the
/// multi-selection counterpart of [DropdownFieldWidget]: same title, styling
/// and validation message, with the options embedded in the form definition.
class MultiSelectFieldWidget extends StatelessWidget {
  final MultiSelectFormFieldModel multiSelectFormFieldModel;
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
  final Color primaryColor;
  final double fieldIconSize;
  final bool? showValidationMessage;
  final void Function(List<Map<String, dynamic>>)? onChanged;

  const MultiSelectFieldWidget({
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
    required this.multiSelectFormFieldModel,
    required this.primaryColor,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.showValidationMessage,
    this.onChanged,
    this.opacity,
    this.fieldHintStyle,
    this.fieldContentPadding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  void _onSelectionChanged(List<Map<String, dynamic>> selectedItems) {
    final selection = List<Map<String, dynamic>>.of(selectedItems);
    multiSelectFormFieldModel.value = selection;
    onChanged?.call(selection);
  }

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return SelectedValuesReadOnlyFieldWidget(
        values: multiSelectFormFieldModel.submittedValue ?? const [],
        title: multiSelectFormFieldModel.title,
        isRequired: multiSelectFormFieldModel.required?.value == true,
        placeholder: multiSelectFormFieldModel.placeholder,
        height: height,
        spacing: spacing,
        innerSpacing: innerSpacing,
        fieldRadius: fieldRadius,
        fieldFillColor: fieldFillColor,
        fieldBorderWidth: fieldBorderWidth,
        fieldBorderColor: fieldBorderColor,
        fieldLabelTextStyle: fieldLabelTextStyle,
        fieldTextStyle: fieldTextStyle,
        fieldHintStyle: fieldHintStyle,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
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
          if (multiSelectFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: multiSelectFormFieldModel.title!,
              isRequired: multiSelectFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          Opacity(
            opacity: opacity ?? 1.0,
            // Selected items are rendered as wrapping chips, so the field only
            // starts at the shared field height and grows with the selection.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: CustomMultiDropdown.search(
                searchHintText: multiSelectFormFieldModel.placeholder,
                contentPadding: EdgeInsets.symmetric(horizontal: innerSpacing),
                borderRadius: BorderRadius.circular(fieldRadius),
                fillColor: fieldFillColor,
                borderSide: BorderSide(
                  color: fieldBorderColor,
                  width: fieldBorderWidth,
                ),
                nameKey: MultiSelectFormFieldModel.optionLabelKey,
                nameMapKey: 'ar',
                primaryIdKey: MultiSelectFormFieldModel.optionValueKey,
                selectColor: primaryColor,
                selectedValues: List<Map<String, dynamic>>.of(
                  multiSelectFormFieldModel.value ?? const [],
                ),
                // The form definition itself decides how many options exist;
                // the field never caps the selection.
                maxSelectedItems: null,
                hintText: multiSelectFormFieldModel.placeholder,
                items: multiSelectFormFieldModel.data,
                onChanged: _onSelectionChanged,
                hintStyle: fieldHintStyle,
                labelStyle: fieldLabelTextStyle,
                listItemStyle: fieldTextStyle,
                selectedStyle: fieldTextStyle,
                // Same trailing icon as the single dropdown next to it, in
                // place of the dropdown's default clear button.
                fieldSuffixIcon: const Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: Color(0xff9E9E9E),
                  size: 20.0,
                ),
              ),
            ),
          ),
          FieldValidationMessageWidget(
            requiredValidation: multiSelectFormFieldModel.required,
            showValidationMessage: showValidationMessage,
          ),
        ],
      ),
    );
  }
}
