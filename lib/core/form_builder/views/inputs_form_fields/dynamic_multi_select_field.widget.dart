part of '../../../../omni_core.dart';

/// Renders a [DynamicMultiSelectFormFieldModel] using
/// [DynamicCustomMultiDropdown], so dynamic multi-selects look and behave
/// exactly like the static [MultiSelectFieldWidget] while loading their
/// options page by page through [optionsFetcher], with server-side search.
///
/// When the field depends on another dropdown, it stays disabled until
/// [parentValue] is provided and clears its selection whenever [parentValue]
/// changes.
class DynamicMultiSelectFieldWidget extends StatefulWidget {
  final DynamicMultiSelectFormFieldModel dynamicMultiSelectFormFieldModel;

  /// May be null only for read-only rendering, where no options are loaded.
  final DynamicDropdownOptionsFetcher? optionsFetcher;

  /// Selected id of the parent dropdown, when this field depends on one.
  final Object? parentValue;
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
  final String searchHintText;
  final String retryButtonText;
  final String noResultsText;
  final String loadFailedText;
  final void Function(List<Map<String, dynamic>>)? onChanged;

  const DynamicMultiSelectFieldWidget({
    super.key,
    required this.dynamicMultiSelectFormFieldModel,
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
    required this.primaryColor,
    this.optionsFetcher,
    this.parentValue,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.showValidationMessage,
    this.onChanged,
    this.opacity,
    this.fieldHintStyle,
    this.fieldContentPadding,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.searchHintText = 'Search',
    this.retryButtonText = 'Retry',
    this.noResultsText = 'No results',
    this.loadFailedText = 'Failed to load options',
  });

  @override
  State<DynamicMultiSelectFieldWidget> createState() =>
      _DynamicMultiSelectFieldWidgetState();
}

class _DynamicMultiSelectFieldWidgetState
    extends State<DynamicMultiSelectFieldWidget> {
  DynamicMultiSelectFormFieldModel get _fieldModel =>
      widget.dynamicMultiSelectFormFieldModel;

  bool get _isEnabled =>
      !_fieldModel.isDependent || widget.parentValue != null;

  bool get _canLoadOptions =>
      widget.optionsFetcher != null &&
      (_fieldModel.entityConfig?.entityKey?.isNotEmpty ?? false);

  @override
  void didUpdateWidget(covariant DynamicMultiSelectFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_fieldModel.isDependent &&
        widget.parentValue != oldWidget.parentValue) {
      _clearSelection();
    }
  }

  void _clearSelection() {
    if (_fieldModel.value?.isEmpty ?? true) return;
    _fieldModel.value = const [];
    // Parent rebuilds may still be in progress; notify after this frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged?.call(const []);
    });
  }

  Future<DynamicDropdownItemsPage?> _loadOptions(
    int offset,
    int limit,
    String? search,
  ) async {
    final optionsFetcher = widget.optionsFetcher;
    final entityConfig = _fieldModel.entityConfig;
    if (optionsFetcher == null || entityConfig == null) return null;

    final page = await optionsFetcher(
      DynamicDropdownOptionsRequestModel(
        entityKey: entityConfig.entityKey!,
        displayField: entityConfig.displayField,
        limit: limit,
        offset: offset,
        search: search,
        parentEntityKey: entityConfig.dependsOn?.parentEntityKey,
        parentValue: widget.parentValue,
      ),
    );
    return page == null
        ? null
        : DynamicDropdownItemsPage(items: page.items, hasMore: page.hasMore);
  }

  /// Keeps the selection in the `{ id, displayValue, entityKey }` shape the
  /// backend expects, exactly like a single dynamic dropdown does.
  void _onSelectionChanged(List<Map<String, dynamic>> selectedItems) {
    final entityConfig = _fieldModel.entityConfig;
    if (entityConfig == null) return;

    final selection = selectedItems
        .map(
          (item) => <String, dynamic>{
            DynamicMultiSelectFormFieldModel.optionIdKey:
                item[DynamicMultiSelectFormFieldModel.optionIdKey] ??
                item[entityConfig.valueField],
            DynamicMultiSelectFormFieldModel.optionDisplayValueKey:
                item[DynamicMultiSelectFormFieldModel.optionDisplayValueKey],
            'entityKey': entityConfig.entityKey,
          },
        )
        .toList();

    setState(() => _fieldModel.value = selection);
    widget.onChanged?.call(selection);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReadOnly) {
      return SelectedValuesReadOnlyFieldWidget(
        values: _fieldModel.submittedValue ?? const [],
        title: _fieldModel.title,
        isRequired: _fieldModel.required?.value == true,
        placeholder: _fieldModel.placeholder,
        height: widget.height,
        spacing: widget.spacing,
        innerSpacing: widget.innerSpacing,
        fieldRadius: widget.fieldRadius,
        fieldFillColor: widget.fieldFillColor,
        fieldBorderWidth: widget.fieldBorderWidth,
        fieldBorderColor: widget.fieldBorderColor,
        fieldLabelTextStyle: widget.fieldLabelTextStyle,
        fieldTextStyle: widget.fieldTextStyle,
        fieldHintStyle: widget.fieldHintStyle,
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.spacing),
      margin: EdgeInsets.only(bottom: widget.spacing),
      child: Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        spacing: widget.innerSpacing,
        children: [
          if (_fieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: _fieldModel.title!,
              isRequired: _fieldModel.required?.value == true,
              style: widget.fieldLabelTextStyle,
            ),
          Opacity(
            opacity: _isEnabled ? (widget.opacity ?? 1.0) : 0.5,
            // Selected items are rendered as wrapping chips, so the field only
            // starts at the shared field height and grows with the selection.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.height),
              child: DynamicCustomMultiDropdown(
                enabled: _isEnabled && _canLoadOptions,
                itemsLoader: _loadOptions,
                nameKey:
                    DynamicMultiSelectFormFieldModel.optionDisplayValueKey,
                primaryIdKey: DynamicMultiSelectFormFieldModel.optionIdKey,
                selectColor: widget.primaryColor,
                selectedValues: _fieldModel.value,
                hintText: _fieldModel.placeholder,
                searchHintText: widget.searchHintText,
                noResultsText: widget.noResultsText,
                loadFailedText: widget.loadFailedText,
                retryText: widget.retryButtonText,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.innerSpacing,
                ),
                borderRadius: BorderRadius.circular(widget.fieldRadius),
                fillColor: widget.fieldFillColor,
                borderSide: BorderSide(
                  color: widget.fieldBorderColor,
                  width: widget.fieldBorderWidth,
                ),
                hintStyle: widget.fieldHintStyle,
                labelStyle: widget.fieldLabelTextStyle,
                selectedStyle: widget.fieldTextStyle,
                // Same trailing icon as the single dropdown next to it, in
                // place of the dropdown's default clear button.
                fieldSuffixIcon: Icon(
                  _isEnabled ? Icons.keyboard_arrow_down_outlined : Icons.lock,
                  color: const Color(0xff9E9E9E),
                  size: 20.0,
                ),
                onChanged: _onSelectionChanged,
              ),
            ),
          ),
          FieldValidationMessageWidget(
            requiredValidation: _fieldModel.required,
            showValidationMessage: widget.showValidationMessage,
          ),
        ],
      ),
    );
  }
}
