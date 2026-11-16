part of 'custom_dropdown.dart';

/// Read-only counterpart of [CustomMultiDropdown]: the very same field box and
/// selection chips, with no overlay, no clear button and no chip delete icons.
///
/// Use it wherever a multi-selection is only being displayed, so it keeps the
/// look of the editable dropdown it mirrors.
class CustomMultiDropdownReadOnlyField extends StatelessWidget {
  final List<Map<String, dynamic>> selectedItems;
  final String? nameKey;
  final String? nameMapKey;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? selectedStyle;
  final Widget? label;
  final TextStyle? labelStyle;
  final String? labelText;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final Widget? prefixIcon;
  final Color? selectedItemChipBackgroundColor;
  final Widget Function(Map<String, dynamic>)? chipBuilder;

  const CustomMultiDropdownReadOnlyField({
    super.key,
    required this.selectedItems,
    required this.nameKey,
    this.nameMapKey,
    this.hintText,
    this.hintStyle,
    this.selectedStyle,
    this.label,
    this.labelStyle,
    this.labelText,
    this.borderSide,
    this.borderRadius,
    this.fillColor,
    this.contentPadding,
    this.prefixIcon,
    this.selectedItemChipBackgroundColor,
    this.chipBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedHintStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFFA7A7A7),
      fontWeight: FontWeight.w400,
    ).merge(hintStyle);

    final resolvedSelectedStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ).merge(selectedStyle);

    return _MultiSelectDropDownField(
      isReadOnly: true,
      selectedItems: selectedItems,
      nameKey: nameKey,
      nameMapKey: nameMapKey,
      onTap: () {},
      label: label,
      labelStyle: labelStyle,
      labelText: labelText,
      hintText: hintText ?? 'Select items',
      hintStyle: resolvedHintStyle,
      style: resolvedSelectedStyle,
      borderRadius: borderRadius,
      borderSide: borderSide,
      fillColor: fillColor,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon,
      selectedItemChipBackgroundColor: selectedItemChipBackgroundColor,
      chipBuilder: chipBuilder,
    );
  }
}
