part of 'custom_dropdown.dart';

/// A page of items returned by a [DynamicDropdownItemsLoader].
class DynamicDropdownItemsPage {
  final List<Map<String, dynamic>> items;
  final bool hasMore;

  const DynamicDropdownItemsPage({required this.items, this.hasMore = false});
}

/// Loads one page of dropdown items, typically from an API.
///
/// [offset] is the number of items already loaded, [limit] the page size and
/// [search] the current server-side search term (null when empty). Return
/// `null` (or throw) to signal a failed load; the overlay then shows a retry
/// state. Cascading/dependent behavior is achieved by capturing the parent
/// value inside the loader closure.
typedef DynamicDropdownItemsLoader = Future<DynamicDropdownItemsPage?> Function(
  int offset,
  int limit,
  String? search,
);

/// A dropdown for dynamic (API-driven) data that matches [CustomDropdown]'s
/// look, feel and behavior: same anchored overlay, animations, styling and
/// interactions, plus paged loading, server-side search and error/retry
/// handling.
///
/// The existing [CustomDropdown] remains untouched and should still be used
/// for static item lists.
class DynamicCustomDropdown extends StatefulWidget {
  final DynamicDropdownItemsLoader itemsLoader;
  final Map<String, dynamic>? selectedValue;

  /// Key of the item map used as display text (e.g. `displayValue`).
  final String nameKey;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? selectedStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final TextStyle? listItemStyle;
  final BorderSide? borderSide;
  final BorderSide? errorBorderSide;
  final BorderRadius? borderRadius;
  final Widget? fieldSuffixIcon;
  final Widget? fieldPrefixIcon;
  final Function(Map<String, dynamic>)? onChanged;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final bool canCloseOutsideBounds;
  final double? customOverRelayWidth;
  final Widget? label;
  final TextStyle? labelStyle;
  final String? labelText;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onRemoveClicked;
  final String? searchHintText;

  /// When false the field absorbs taps (e.g. a dependent dropdown whose
  /// parent has no value yet).
  final bool enabled;
  final bool enableSearch;
  final String noResultsText;
  final String loadFailedText;
  final String retryText;
  final int pageSize;
  final Duration searchDebounce;

  const DynamicCustomDropdown({
    super.key,
    required this.itemsLoader,
    this.nameKey = 'name',
    this.selectedValue,
    this.hintText,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.listItemStyle,
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
    this.validator,
    this.autovalidateMode,
    this.onRemoveClicked,
    this.searchHintText,
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
  DynamicCustomDropdownState createState() => DynamicCustomDropdownState();
}

class DynamicCustomDropdownState extends State<DynamicCustomDropdown> {
  final layerLink = LayerLink();
  late TextEditingController textEditingController;
  String? _initSelected;

  String? get widgetSelectedValue =>
      widget.selectedValue?[widget.nameKey]?.toString();

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: widgetSelectedValue);
    _initSelected = textEditingController.text;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  /// Syncs the controller text with the current [widget.selectedValue].
  ///
  /// The controller is attached to a TextFormField whose change listener
  /// marks the enclosing Form dirty, so it must never be mutated during
  /// build (e.g. when a dependent dropdown is cleared because its parent
  /// changed). The update is deferred to after the current frame.
  void _syncSelectedValue() {
    if (_initSelected == widgetSelectedValue) return;
    _initSelected = widgetSelectedValue;
    final selectedText = widgetSelectedValue ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && textEditingController.text != selectedText) {
        textEditingController.text = selectedText;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _syncSelectedValue();

    final hintText = widget.hintText ?? 'Select value';

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
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: AbsorbPointer(
        absorbing: !widget.enabled,
        child: _OverlayBuilder(
          overlay: (size, hideCallback) {
            return _DynamicDropdownOverlay(
              itemsLoader: widget.itemsLoader,
              nameKey: widget.nameKey,
              controller: textEditingController,
              size: size,
              layerLink: layerLink,
              hideOverlay: hideCallback,
              headerStyle: (textEditingController.text.isNotEmpty)
                  ? selectedStyle
                  : hintStyle,
              hintText: hintText,
              listItemStyle: widget.listItemStyle,
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
              onItemSelected: (item) {
                widget.onChanged?.call(item);
                FocusScope.of(context).unfocus();
              },
            );
          },
          child: (showCallback) {
            return CompositedTransformTarget(
              link: layerLink,
              child: _DropDownField(
                label: widget.label,
                labelStyle: widget.labelStyle,
                labelText: widget.labelText,
                onRemoveClicked: widget.onRemoveClicked,
                isItemsNullOrEmpty: !widget.enabled,
                controller: textEditingController,
                validator: widget.validator,
                autovalidateMode: widget.autovalidateMode,
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
