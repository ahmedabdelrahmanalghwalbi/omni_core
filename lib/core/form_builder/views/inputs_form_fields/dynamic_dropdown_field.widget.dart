part of '../../../../omni_core.dart';

/// Renders a [DynamicDropdownFormFieldModel] using [DynamicCustomDropdown],
/// so dynamic dropdowns look and behave exactly like the static
/// [DropdownFieldWidget] while loading their options page by page through
/// [optionsFetcher], with server-side search.
///
/// When the field depends on another dropdown, it stays disabled until
/// [parentValue] is provided and clears its selection whenever [parentValue]
/// changes.
class DynamicDropdownFieldWidget extends StatefulWidget {
  final DynamicDropdownFormFieldModel dynamicDropdownFormFieldModel;

  /// May be null only for read-only rendering, where no options are loaded.
  final DynamicDropdownOptionsFetcher? optionsFetcher;

  /// Selected id of the parent dropdown, when this field depends on one.
  final Object? parentValue;

  /// Entity properties requested with the options and kept on the selected
  /// value, so derived fields reading them keep working offline.
  final List<String> includeProperties;
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
  final void Function(Map<String, dynamic>?)? onChanged;

  const DynamicDropdownFieldWidget({
    super.key,
    required this.dynamicDropdownFormFieldModel,
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
    this.includeProperties = const [],
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
  State<DynamicDropdownFieldWidget> createState() =>
      _DynamicDropdownFieldWidgetState();
}

class _DynamicDropdownFieldWidgetState
    extends State<DynamicDropdownFieldWidget> {
  DynamicDropdownFormFieldModel get _fieldModel =>
      widget.dynamicDropdownFormFieldModel;

  bool get _isEnabled => !_fieldModel.isDependent || widget.parentValue != null;

  bool get _canLoadOptions =>
      widget.optionsFetcher != null &&
      (_fieldModel.entityConfig?.entityKey?.isNotEmpty ?? false);

  @override
  void didUpdateWidget(covariant DynamicDropdownFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_fieldModel.isDependent &&
        widget.parentValue != oldWidget.parentValue) {
      _clearSelection();
    }
  }

  void _clearSelection() {
    if (_fieldModel.value == null) return;
    _fieldModel.value = null;
    // Parent rebuilds may still be in progress; notify after this frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged?.call(null);
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
        includeProperties: widget.includeProperties,
      ),
    );
    return page == null
        ? null
        : DynamicDropdownItemsPage(items: page.items, hasMore: page.hasMore);
  }

  void _onItemSelected(Map<String, dynamic> item) {
    final entityConfig = _fieldModel.entityConfig;
    if (entityConfig == null) return;

    final value = {
      'id': item['id'] ?? item[entityConfig.valueField],
      'displayValue': item['displayValue'],
      'entityKey': entityConfig.entityKey,
      // Kept with the selection so a derived field reads the property without
      // another request, and still reads it from a restored draft or offline.
      for (final property in widget.includeProperties)
        if (item[property] != null) property: item[property],
    };
    setState(() => _fieldModel.value = value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReadOnly) {
      return TextFieldWidget(
        textFormFieldModel: TextFormFieldModel(
          css: _fieldModel.css,
          key: _fieldModel.key,
          placeholder: _fieldModel.placeholder,
          required: _fieldModel.required,
          submittedValue: _fieldModel.submittedValue,
          title: _fieldModel.title,
        ),
        fieldBorderColor: widget.fieldBorderColor,
        fieldBorderWidth: widget.fieldBorderWidth,
        fieldFillColor: widget.fieldFillColor,
        fieldHeight: widget.height,
        fieldIconSize: widget.fieldIconSize,
        fieldLabelTextStyle: widget.fieldLabelTextStyle,
        fieldRadius: widget.fieldRadius,
        fieldTextStyle: widget.fieldTextStyle,
        spacing: widget.spacing,
        innerSpacing: widget.innerSpacing,
        isReadOnly: true,
        primaryColor: widget.primaryColor,
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        fieldHintStyle: widget.fieldHintStyle,
        fieldContentPadding: widget.fieldContentPadding,
        showValidationMessage: false,
        onChanged: (_) {},
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
            child: SizedBox(
              height: widget.height,
              child: DynamicCustomDropdown(
                enabled: _isEnabled && _canLoadOptions,
                itemsLoader: _loadOptions,
                nameKey: 'displayValue',
                selectedValue: _fieldModel.value,
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
                listItemStyle: widget.fieldTextStyle,
                selectedStyle: widget.fieldTextStyle,
                fieldSuffixIcon: Icon(
                  _isEnabled ? Icons.keyboard_arrow_down_outlined : Icons.lock,
                  color: const Color(0xff9E9E9E),
                  size: 20.0,
                ),
                onChanged: _onItemSelected,
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
