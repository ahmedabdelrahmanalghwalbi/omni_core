part of 'custom_dropdown.dart';

/// A multi-select dropdown for dynamic (API-driven) data.
///
/// It is to [CustomMultiDropdown] what [DynamicCustomDropdown] is to
/// [CustomDropdown]: the same anchored overlay, chips field, styling and
/// interactions, with paged loading, server-side search and error/retry
/// handling instead of a static item list.
class DynamicCustomMultiDropdown extends StatefulWidget {
  final DynamicDropdownItemsLoader itemsLoader;
  final List<Map<String, dynamic>>? selectedValues;

  /// Key of the item map used as display text (e.g. `displayValue`).
  final String nameKey;

  /// Key identifying an item, used to compare selections (e.g. `id`).
  final String primaryIdKey;
  final String? subNameKey;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? selectedStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final BorderSide? borderSide;
  final BorderSide? errorBorderSide;
  final BorderRadius? borderRadius;
  final Widget? fieldSuffixIcon;
  final Widget? fieldPrefixIcon;
  final Function(List<Map<String, dynamic>>)? onChanged;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final bool canCloseOutsideBounds;
  final double? customOverRelayWidth;
  final Widget? label;
  final TextStyle? labelStyle;
  final String? labelText;
  final Widget Function(Map<String, dynamic>)? chipBuilder;
  final Color? selectedItemChipBackgroundColor;
  final Color selectColor;
  final void Function()? onRemoveClicked;
  final String? searchHintText;

  /// Null means no limit.
  final int? maxSelectedItems;
  final VoidCallback? onMaxItemsSelected;

  /// When false the field absorbs taps (e.g. a dependent multi-select whose
  /// parent has no value yet).
  final bool enabled;
  final bool enableSearch;
  final String noResultsText;
  final String loadFailedText;
  final String retryText;
  final int pageSize;
  final Duration searchDebounce;

  const DynamicCustomMultiDropdown({
    super.key,
    required this.itemsLoader,
    required this.primaryIdKey,
    this.nameKey = 'name',
    this.subNameKey,
    this.selectedValues,
    this.hintText,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.borderSide,
    this.errorBorderSide,
    this.borderRadius,
    this.fieldSuffixIcon,
    this.fieldPrefixIcon,
    this.onChanged,
    this.contentPadding,
    this.customOverRelayWidth,
    this.label,
    this.labelStyle,
    this.labelText,
    this.chipBuilder,
    this.selectedItemChipBackgroundColor,
    this.onRemoveClicked,
    this.searchHintText,
    this.maxSelectedItems,
    this.onMaxItemsSelected,
    this.selectColor = Colors.black,
    this.enabled = true,
    this.enableSearch = true,
    this.canCloseOutsideBounds = true,
    this.fillColor = Colors.white,
    this.noResultsText = 'No result found.',
    this.loadFailedText = 'Failed to load data.',
    this.retryText = 'Retry',
    this.pageSize = 50,
    this.searchDebounce = const Duration(milliseconds: 500),
  });

  @override
  DynamicCustomMultiDropdownState createState() =>
      DynamicCustomMultiDropdownState();
}

class DynamicCustomMultiDropdownState
    extends State<DynamicCustomMultiDropdown> {
  final layerLink = LayerLink();
  late List<Map<String, dynamic>> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.of(widget.selectedValues ?? const []);
  }

  /// Adopts [DynamicCustomMultiDropdown.selectedValues] only when it actually
  /// differs from the current selection, so a rebuild triggered by this
  /// dropdown's own [DynamicCustomMultiDropdown.onChanged] never fights the
  /// user, while an external change (e.g. a dependent field cleared by its
  /// parent) is applied.
  @override
  void didUpdateWidget(covariant DynamicCustomMultiDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_identityOf(widget.selectedValues) != _identityOf(_selectedItems)) {
      // Updated in place: an open overlay renders the very same list.
      setState(() {
        _selectedItems
          ..clear()
          ..addAll(widget.selectedValues ?? const []);
      });
    }
  }

  String _identityOf(List<Map<String, dynamic>>? items) =>
      (items ?? const []).map((item) => item[widget.primaryIdKey]).join('|');

  void _onItemToggled(Map<String, dynamic> item) {
    final selectedIndex = _selectedItems.indexWhere(
      (selected) =>
          selected[widget.primaryIdKey].toString() ==
          item[widget.primaryIdKey].toString(),
    );

    if (selectedIndex != -1) {
      setState(() => _selectedItems.removeAt(selectedIndex));
    } else if (widget.maxSelectedItems != null &&
        _selectedItems.length >= widget.maxSelectedItems!) {
      widget.onMaxItemsSelected?.call();
      return;
    } else {
      setState(() => _selectedItems.add(item));
    }
    widget.onChanged?.call(List.of(_selectedItems));
  }

  void _onItemRemoved(Map<String, dynamic> item) {
    setState(() => _selectedItems.remove(item));
    widget.onChanged?.call(List.of(_selectedItems));
  }

  void _clearSelection() {
    setState(() => _selectedItems.clear());
    widget.onChanged?.call(List.of(_selectedItems));
    widget.onRemoveClicked?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hintText = widget.hintText ?? 'Select items';

    final hintStyle = const TextStyle(
      fontSize: 16,
      color: Color(0xFFA7A7A7),
      fontWeight: FontWeight.w400,
    ).merge(widget.hintStyle);

    final selectedStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ).merge(widget.selectedStyle);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: AbsorbPointer(
        absorbing: !widget.enabled,
        child: _OverlayBuilder(
          overlay: (size, hideCallback) {
            return _DynamicMultiSelectDropdownOverlay(
              itemsLoader: widget.itemsLoader,
              nameKey: widget.nameKey,
              subNameKey: widget.subNameKey,
              primaryIdKey: widget.primaryIdKey,
              selectedItems: _selectedItems,
              selectColor: widget.selectColor,
              size: size,
              layerLink: layerLink,
              hideOverlay: hideCallback,
              headerStyle: _selectedItems.isNotEmpty
                  ? selectedStyle
                  : hintStyle,
              hintText: hintText,
              canCloseOutsideBounds: widget.canCloseOutsideBounds,
              enableSearch: widget.enableSearch,
              searchHintText: widget.searchHintText,
              borderRadius: widget.borderRadius,
              customOverRelayWidth: widget.customOverRelayWidth,
              noResultsText: widget.noResultsText,
              loadFailedText: widget.loadFailedText,
              retryText: widget.retryText,
              pageSize: widget.pageSize,
              searchDebounce: widget.searchDebounce,
              maxSelectedItems: widget.maxSelectedItems,
              onItemSelected: _onItemToggled,
            );
          },
          child: (showCallback) {
            return CompositedTransformTarget(
              link: layerLink,
              child: _MultiSelectDropDownField(
                selectedItems: _selectedItems,
                nameKey: widget.nameKey,
                label: widget.label,
                labelStyle: widget.labelStyle,
                labelText: widget.labelText,
                isItemsNullOrEmpty: !widget.enabled,
                onItemRemoved: _onItemRemoved,
                onRemoveClicked: _clearSelection,
                selectedItemChipBackgroundColor:
                    widget.selectedItemChipBackgroundColor,
                chipBuilder: widget.chipBuilder,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  showCallback();
                },
                style: selectedStyle,
                borderRadius: widget.borderRadius,
                borderSide: widget.borderSide,
                errorBorderSide: widget.errorBorderSide,
                errorStyle: widget.errorStyle,
                errorText: widget.errorText,
                hintStyle: hintStyle,
                hintText: hintText,
                prefixIcon: widget.fieldPrefixIcon,
                suffixIcon: widget.fieldSuffixIcon,
                fillColor: widget.fillColor,
                contentPadding: widget.contentPadding,
              ),
            );
          },
        ),
      ),
    );
  }
}
