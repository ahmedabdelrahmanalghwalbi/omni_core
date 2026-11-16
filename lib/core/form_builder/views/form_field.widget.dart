part of '../../../omni_core.dart';

enum ImageShape { circle, rectangle }

class FormFieldWidget extends StatefulWidget {
  final FormFieldModel? fieldModel;

  /// The fields [fieldModel] shares its scope with: the flattened top-level
  /// fields, or the fields of the repeating-group item it belongs to.
  ///
  /// Supplying it enables the schema-driven behaviors that need to resolve
  /// other fields — conditional visibility, and requesting the entity
  /// properties the derived fields of the scope read. Left null, the field
  /// renders exactly as before.
  final List<FormFieldModel>? scopeFields;
  final bool readOnly;
  final bool isEditMode;
  final Color primaryColor;
  final Locale locale;
  final double spacing;
  final double innerSpacing;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderSize;
  final Color fieldBorderColor;
  final double fieldHeight;
  final double fieldIconSize;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final TextStyle fieldHintStyle;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool? showValidationMessageForInputsFieldsOnly;
  final EdgeInsetsGeometry? fieldContentPadding;
  final int? textAreaFieldMinLine;
  final double? progressLineFieldHeight;
  final double? progressCircleFieldRadiusSize;
  final double? imageFieldSize;
  final ImageShape? imageFieldShape;
  final DateTime? dateTimeFieldfirstDateTime;
  final DateTime? dateTimeFieldlastDateTime;
  final String? dateTimeFieldCancelText;
  final String? dateTimeFieldConfirmText;
  final String? dateTimeFieldInvalidDateFormatText;
  final String? dateTimeFieldOutOfRangeDateText;
  final VoidCallback? dateTimeFieldOnPickeingDateTimeFailed;
  final TextStyle? radioGroupFieldOptionTextStyle;
  final Color? radioGroupFieldInActiveColor;
  final double? radioGroupFieldRadioSize;
  final double? dropdownFieldOpacity;
  final bool? showDropdownFieldPrefixLoading;

  /// Loads options for dynamic dropdown fields. Dynamic dropdowns are not
  /// rendered when this is null.
  final DynamicDropdownOptionsFetcher? dynamicDropdownOptionsFetcher;

  /// Resolves the current value of another field by its key, so dependent
  /// dynamic dropdowns can read their parent's selection.
  final dynamic Function(String parentFieldKey)?
  dynamicDropdownParentValueResolver;
  final String? dynamicDropdownSearchHintText;
  final String? dynamicDropdownRetryButtonText;
  final String? dynamicDropdownNoResultsText;
  final String? dynamicDropdownLoadFailedText;
  final Color? signatureFieldFillColor;
  final double? signatureFieldHeight;
  final String? signatureFieldClearButtonText;
  final Color? uploaderFieldFillColor;

  /// Lets the user annotate PDFs of uploader fields before uploading them.
  final bool uploaderFieldEnablePdfAnnotation;
  final PdfAnnotationTexts? uploaderFieldPdfAnnotationTexts;
  final double? takePhotoFieldSize;
  final String? takePhotoFieldSelectOptionText;
  final String? takePhotoFieldTakePhotoText;
  final String? takePhotoFieldChooseFromGalleryText;
  final ImageShape? takePhotoFieldShape;
  final VoidCallback? takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed;
  final VoidCallback? takePhotoFieldOnSelectOrPickPhotoFailed;
  final void Function(String formFieldUniqueKey, dynamic formFieldValue)
  onChanged;

  /// Adds an item to the repeating group with the given key.
  final void Function(String groupFieldKey)? onRepeatingGroupAddItem;

  /// Deletes the item at the given index of a repeating group. The host
  /// confirms the deletion when the item already holds data.
  final void Function(String groupFieldKey, int itemIndex)?
  onRepeatingGroupDeleteItem;

  /// Expands or collapses the item at the given index of a repeating group.
  final void Function(String groupFieldKey, int itemIndex, bool isExpanded)?
  onRepeatingGroupItemExpandedChanged;

  /// Reports a change inside one repeating-group item, so the host can prune
  /// hidden values, recalculate and persist the draft for that item's scope.
  final void Function(
    String groupFieldKey,
    int itemIndex,
    String fieldKey,
    dynamic value,
  )?
  onRepeatingGroupItemFieldChanged;

  final String? repeatingGroupEmptyStateText;
  final String? repeatingGroupAddItemText;
  final String? repeatingGroupItemLabelText;
  final String? repeatingGroupDeleteItemText;
  final String? repeatingGroupEditItemText;
  final String? repeatingGroupMaxItemsReachedText;
  final String? repeatingGroupMinItemsRequiredText;

  const FormFieldWidget({
    super.key,
    required this.fieldModel,
    required this.primaryColor,
    required this.locale,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderSize,
    required this.fieldBorderColor,
    required this.fieldHeight,
    required this.fieldIconSize,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    required this.fieldHintStyle,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.onChanged,
    this.fieldContentPadding,
    this.textAreaFieldMinLine,
    this.progressLineFieldHeight,
    this.progressCircleFieldRadiusSize,
    this.imageFieldSize,
    this.imageFieldShape,
    this.dateTimeFieldfirstDateTime,
    this.dateTimeFieldlastDateTime,
    this.dateTimeFieldCancelText,
    this.dateTimeFieldConfirmText,
    this.dateTimeFieldInvalidDateFormatText,
    this.dateTimeFieldOutOfRangeDateText,
    this.dateTimeFieldOnPickeingDateTimeFailed,
    this.radioGroupFieldOptionTextStyle,
    this.radioGroupFieldInActiveColor,
    this.radioGroupFieldRadioSize,
    this.dropdownFieldOpacity,
    this.showDropdownFieldPrefixLoading,
    this.dynamicDropdownOptionsFetcher,
    this.dynamicDropdownParentValueResolver,
    this.dynamicDropdownSearchHintText,
    this.dynamicDropdownRetryButtonText,
    this.dynamicDropdownNoResultsText,
    this.dynamicDropdownLoadFailedText,
    this.signatureFieldFillColor,
    this.signatureFieldHeight,
    this.signatureFieldClearButtonText,
    this.uploaderFieldFillColor,
    this.uploaderFieldEnablePdfAnnotation = false,
    this.uploaderFieldPdfAnnotationTexts,
    this.takePhotoFieldSize,
    this.takePhotoFieldSelectOptionText,
    this.takePhotoFieldTakePhotoText,
    this.takePhotoFieldChooseFromGalleryText,
    this.takePhotoFieldShape,
    this.takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed,
    this.takePhotoFieldOnSelectOrPickPhotoFailed,
    this.showValidationMessageForInputsFieldsOnly,
    this.scopeFields,
    this.onRepeatingGroupAddItem,
    this.onRepeatingGroupDeleteItem,
    this.onRepeatingGroupItemExpandedChanged,
    this.onRepeatingGroupItemFieldChanged,
    this.repeatingGroupEmptyStateText,
    this.repeatingGroupAddItemText,
    this.repeatingGroupItemLabelText,
    this.repeatingGroupDeleteItemText,
    this.repeatingGroupEditItemText,
    this.repeatingGroupMaxItemsReachedText,
    this.repeatingGroupMinItemsRequiredText,
    this.readOnly = false,
    this.isEditMode = false,
  });

  /// The same field configuration applied to another field.
  ///
  /// Keeps every style, label and callback of this dispatcher, so a nested
  /// renderer — the items of a repeating group — builds its children exactly
  /// like the rest of the form without restating the configuration.
  FormFieldWidget copyForField(
    FormFieldModel field, {
    Key? key,
    List<FormFieldModel>? scopeFields,
    void Function(String formFieldUniqueKey, dynamic formFieldValue)? onChanged,
    dynamic Function(String parentFieldKey)? dynamicDropdownParentValueResolver,
    bool? showValidationMessageForInputsFieldsOnly,
  }) => FormFieldWidget(
    key: key,
    fieldModel: field,
    scopeFields: scopeFields ?? this.scopeFields,
    onChanged: onChanged ?? this.onChanged,
    dynamicDropdownParentValueResolver:
        dynamicDropdownParentValueResolver ??
        this.dynamicDropdownParentValueResolver,
    showValidationMessageForInputsFieldsOnly:
        showValidationMessageForInputsFieldsOnly ??
        this.showValidationMessageForInputsFieldsOnly,
    readOnly: readOnly,
    isEditMode: isEditMode,
    primaryColor: primaryColor,
    locale: locale,
    spacing: spacing,
    innerSpacing: innerSpacing,
    fieldRadius: fieldRadius,
    fieldFillColor: fieldFillColor,
    fieldBorderSize: fieldBorderSize,
    fieldBorderColor: fieldBorderColor,
    fieldHeight: fieldHeight,
    fieldIconSize: fieldIconSize,
    fieldLabelTextStyle: fieldLabelTextStyle,
    fieldTextStyle: fieldTextStyle,
    fieldHintStyle: fieldHintStyle,
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    fieldContentPadding: fieldContentPadding,
    textAreaFieldMinLine: textAreaFieldMinLine,
    progressLineFieldHeight: progressLineFieldHeight,
    progressCircleFieldRadiusSize: progressCircleFieldRadiusSize,
    imageFieldSize: imageFieldSize,
    imageFieldShape: imageFieldShape,
    dateTimeFieldfirstDateTime: dateTimeFieldfirstDateTime,
    dateTimeFieldlastDateTime: dateTimeFieldlastDateTime,
    dateTimeFieldCancelText: dateTimeFieldCancelText,
    dateTimeFieldConfirmText: dateTimeFieldConfirmText,
    dateTimeFieldInvalidDateFormatText: dateTimeFieldInvalidDateFormatText,
    dateTimeFieldOutOfRangeDateText: dateTimeFieldOutOfRangeDateText,
    dateTimeFieldOnPickeingDateTimeFailed: dateTimeFieldOnPickeingDateTimeFailed,
    radioGroupFieldOptionTextStyle: radioGroupFieldOptionTextStyle,
    radioGroupFieldInActiveColor: radioGroupFieldInActiveColor,
    radioGroupFieldRadioSize: radioGroupFieldRadioSize,
    dropdownFieldOpacity: dropdownFieldOpacity,
    showDropdownFieldPrefixLoading: showDropdownFieldPrefixLoading,
    dynamicDropdownOptionsFetcher: dynamicDropdownOptionsFetcher,
    dynamicDropdownSearchHintText: dynamicDropdownSearchHintText,
    dynamicDropdownRetryButtonText: dynamicDropdownRetryButtonText,
    dynamicDropdownNoResultsText: dynamicDropdownNoResultsText,
    dynamicDropdownLoadFailedText: dynamicDropdownLoadFailedText,
    signatureFieldFillColor: signatureFieldFillColor,
    signatureFieldHeight: signatureFieldHeight,
    signatureFieldClearButtonText: signatureFieldClearButtonText,
    uploaderFieldFillColor: uploaderFieldFillColor,
    uploaderFieldEnablePdfAnnotation: uploaderFieldEnablePdfAnnotation,
    uploaderFieldPdfAnnotationTexts: uploaderFieldPdfAnnotationTexts,
    takePhotoFieldSize: takePhotoFieldSize,
    takePhotoFieldSelectOptionText: takePhotoFieldSelectOptionText,
    takePhotoFieldTakePhotoText: takePhotoFieldTakePhotoText,
    takePhotoFieldChooseFromGalleryText: takePhotoFieldChooseFromGalleryText,
    takePhotoFieldShape: takePhotoFieldShape,
    takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed:
        takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed,
    takePhotoFieldOnSelectOrPickPhotoFailed:
        takePhotoFieldOnSelectOrPickPhotoFailed,
    onRepeatingGroupAddItem: onRepeatingGroupAddItem,
    onRepeatingGroupDeleteItem: onRepeatingGroupDeleteItem,
    onRepeatingGroupItemExpandedChanged: onRepeatingGroupItemExpandedChanged,
    onRepeatingGroupItemFieldChanged: onRepeatingGroupItemFieldChanged,
    repeatingGroupEmptyStateText: repeatingGroupEmptyStateText,
    repeatingGroupAddItemText: repeatingGroupAddItemText,
    repeatingGroupItemLabelText: repeatingGroupItemLabelText,
    repeatingGroupDeleteItemText: repeatingGroupDeleteItemText,
    repeatingGroupEditItemText: repeatingGroupEditItemText,
    repeatingGroupMaxItemsReachedText: repeatingGroupMaxItemsReachedText,
    repeatingGroupMinItemsRequiredText: repeatingGroupMinItemsRequiredText,
  );

  @override
  State<FormFieldWidget> createState() => _FormFieldWidgetState();
}

class _FormFieldWidgetState extends State<FormFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final fieldModel = widget.fieldModel;
    if (fieldModel == null) return const SizedBox.shrink();

    // A hidden field is not rendered at all; its value is pruned from the
    // scope by the host, which owns the form state.
    final scopeFields = widget.scopeFields;
    if (scopeFields != null &&
        !FormVisibilityUtils.isVisible(
          fieldModel,
          scopeFields,
          useSubmittedValues: widget.readOnly,
        )) {
      return const SizedBox.shrink();
    }

    switch (widget.fieldModel?.type) {
      /// INPUTS FIELDS
      case FormFieldType.input:
        final textFormFieldModel = widget.fieldModel as TextFormFieldModel;
        return TextFieldWidget(
          textFormFieldModel: textFormFieldModel,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldHeight: widget.fieldHeight,
          fieldIconSize: widget.fieldIconSize,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          fieldHintStyle: widget.fieldHintStyle,
          fieldContentPadding: widget.fieldContentPadding,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (value) {
            if (textFormFieldModel.key?.isNotEmpty ?? false) {
              widget.onChanged(textFormFieldModel.key!, value);
            }
          },
        );
      case FormFieldType.numberinput:
        final numberFormFieldModel = widget.fieldModel as NumberFormFieldModel;
        return NumberFieldWidget(
          numberFormFieldModel: numberFormFieldModel,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldHeight: widget.fieldHeight,
          fieldIconSize: widget.fieldIconSize,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          fieldHintStyle: widget.fieldHintStyle,
          fieldContentPadding: widget.fieldContentPadding,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (value) {
            if (numberFormFieldModel.key?.isNotEmpty ?? false) {
              final val = AppBaseModel.parseNum(value);
              widget.onChanged(numberFormFieldModel.key!, val);
            }
          },
        );
      case FormFieldType.textarea:
        final textAreaFormField = widget.fieldModel as TextAreaFormFieldModel;
        return TextAreaFieldWidget(
          textAreaFormFieldModel: textAreaFormField,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldHeight: widget.fieldHeight,
          fieldIconSize: widget.fieldIconSize,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          fieldHintStyle: widget.fieldHintStyle,
          fieldContentPadding: widget.fieldContentPadding,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (value) {
            if (textAreaFormField.key?.isNotEmpty ?? false) {
              widget.onChanged(textAreaFormField.key!, value);
            }
          },
        );
      case FormFieldType.datetime:
        final dateTimepickerFormField =
            widget.fieldModel as DateTimePickerFormFieldModel;
        return DateTimePickerFieldWidget(
          dateTimeFormFieldModel: dateTimepickerFormField,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldHeight: widget.fieldHeight,
          fieldIconSize: widget.fieldIconSize,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          fieldHintStyle: widget.fieldHintStyle,
          fieldContentPadding: widget.fieldContentPadding,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          locale: widget.locale,
          cancelText: widget.dateTimeFieldCancelText ?? 'Cancel',
          confirmText: widget.dateTimeFieldConfirmText ?? 'Confirm',
          invalidDateFormatText: widget.dateTimeFieldInvalidDateFormatText,
          outOfRangeDateText: widget.dateTimeFieldOutOfRangeDateText,
          onPickeingDateTimeFailed:
              widget.dateTimeFieldOnPickeingDateTimeFailed,
          firstDate: widget.dateTimeFieldfirstDateTime ?? DateTime(1990),
          lastDate: widget.dateTimeFieldlastDateTime ?? DateTime(2050),
          onChanged: (value) {
            if (dateTimepickerFormField.key?.isNotEmpty ?? false) {
              widget.onChanged(dateTimepickerFormField.key!, value);
            }
          },
        );
      case FormFieldType.datepicker:
        final datePickerFormField =
            widget.fieldModel as DatePickerFormFieldModel;
        return DatePickerFieldWidget(
          dateFormFieldModel: datePickerFormField,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldHeight: widget.fieldHeight,
          fieldIconSize: widget.fieldIconSize,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          fieldHintStyle: widget.fieldHintStyle,
          fieldContentPadding: widget.fieldContentPadding,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          locale: widget.locale,
          cancelText: widget.dateTimeFieldCancelText ?? 'Cancel',
          confirmText: widget.dateTimeFieldConfirmText ?? 'Confirm',
          invalidDateFormatText: widget.dateTimeFieldInvalidDateFormatText,
          outOfRangeDateText: widget.dateTimeFieldOutOfRangeDateText,
          onPickingDateFailed: widget.dateTimeFieldOnPickeingDateTimeFailed,
          firstDate: widget.dateTimeFieldfirstDateTime ?? DateTime(1990),
          lastDate: widget.dateTimeFieldlastDateTime ?? DateTime(2050),
          onChanged: (value) {
            if (datePickerFormField.key?.isNotEmpty ?? false) {
              widget.onChanged(datePickerFormField.key!, value);
            }
          },
        );
      case FormFieldType.radiogroup:
        final radiogroupFormFieldModel =
            widget.fieldModel as RadioGroupFormFieldModel;
        return RadioGroupFieldWidget(
          radiogroupFormFieldModel: radiogroupFormFieldModel,
          labelTextStyle: widget.fieldLabelTextStyle,
          optionTextStyle:
              widget.radioGroupFieldOptionTextStyle ??
              const TextStyle(
                fontSize: 13.0,
                color: Color(0xff40566D),
                fontWeight: FontWeight.w400,
              ),
          inactiveColor:
              widget.radioGroupFieldInActiveColor ?? const Color(0xffB1C1D2),
          activeColor: widget.primaryColor,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          radioSize: widget.radioGroupFieldRadioSize ?? 16.0,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldHeight: widget.fieldHeight,
          fieldIconSize: widget.fieldIconSize,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (value) {
            if (radiogroupFormFieldModel.key?.isNotEmpty ?? false) {
              widget.onChanged(radiogroupFormFieldModel.key!, value);
            }
          },
        );
      case FormFieldType.toggle:
        final toggleFormField = widget.fieldModel as ToggleFormFieldModel;
        return ToggleFieldWidget(
          toggleFormFieldModel: toggleFormField,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          spacing: widget.spacing,
          fieldHintStyle: widget.fieldHintStyle,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          fieldContentPadding: widget.fieldContentPadding,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (value) {
            if (toggleFormField.key?.isNotEmpty ?? false) {
              widget.onChanged(toggleFormField.key!, value);
            }
          },
        );
      case FormFieldType.checkbox:
        final checkboxFormField = widget.fieldModel as CheckboxFormFieldModel;
        return CheckBoxFieldWidget(
          checkboxFormFieldModel: checkboxFormField,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          fieldIconSize: widget.fieldIconSize,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (value) {
            if (checkboxFormField.key?.isNotEmpty ?? false) {
              widget.onChanged(checkboxFormField.key!, value);
            }
          },
        );
      case FormFieldType.dropdown:
        // Dynamic dropdowns arrive from the backend as `name: "Dropdown"` and
        // are parsed as DynamicDropdownFormFieldModel; the class is the
        // discriminator.
        if (widget.fieldModel
            case final DynamicDropdownFormFieldModel dynamicDropdownFormField) {
          return _buildDynamicDropdownField(dynamicDropdownFormField);
        }
        final dropdownFormField = widget.fieldModel as DropdownFormFieldModel;
        if (dropdownFormField.isFromUrl) {
          // Well-formed dynamic dropdowns are parsed as
          // DynamicDropdownFormFieldModel and handled below; reaching here
          // means the definition has no usable entityConfig.
          PackageLogger.warning(
            'Dropdown "${dropdownFormField.key}" has a non-static queryKey '
            'but no entityConfig; field skipped.',
          );
          return const SizedBox.shrink();
        } else {
          return DropdownFieldWidget(
            dropdownFormFieldModel: dropdownFormField,
            fieldIconSize: widget.fieldIconSize,
            fieldBorderColor: widget.fieldBorderColor,
            fieldBorderWidth: widget.fieldBorderSize,
            fieldFillColor: widget.fieldFillColor,
            fieldLabelTextStyle: widget.fieldLabelTextStyle,
            fieldRadius: widget.fieldRadius,
            fieldTextStyle: widget.fieldTextStyle,
            spacing: widget.spacing,
            innerSpacing: widget.innerSpacing,
            height: widget.fieldHeight,
            isReadOnly: widget.readOnly,
            isEditMode: widget.isEditMode,
            primaryColor: widget.primaryColor,
            fieldContentPadding: widget.fieldContentPadding,
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            fieldHintStyle: widget.fieldHintStyle,
            opacity: widget.dropdownFieldOpacity,
            showValidationMessage:
                widget.showValidationMessageForInputsFieldsOnly,
            showPrefixLoading: widget.showDropdownFieldPrefixLoading,
            onChanged: (value) {
              if (dropdownFormField.key?.isNotEmpty ?? false) {
                widget.onChanged(dropdownFormField.key!, value);
              }
            },
          );
        }
      case FormFieldType.dynamicDropdown:
        return _buildDynamicDropdownField(
          widget.fieldModel as DynamicDropdownFormFieldModel,
        );
      case FormFieldType.multiselect:
        // Dynamic multi-selects arrive from the backend as
        // `name: "MultiSelect"` and are parsed as
        // DynamicMultiSelectFormFieldModel; the class is the discriminator.
        if (widget.fieldModel
            case final DynamicMultiSelectFormFieldModel
                dynamicMultiSelectFormField) {
          return _buildDynamicMultiSelectField(dynamicMultiSelectFormField);
        }
        final multiSelectFormField =
            widget.fieldModel as MultiSelectFormFieldModel;
        // Read-only rendering only shows the submitted values, so it needs
        // neither options nor an entityConfig.
        if (multiSelectFormField.isFromUrl && !widget.readOnly) {
          // Well-formed dynamic multi-selects are parsed as
          // DynamicMultiSelectFormFieldModel and handled above; reaching here
          // means the definition has no usable entityConfig.
          PackageLogger.warning(
            'MultiSelect "${multiSelectFormField.key}" has a non-static '
            'queryKey but no entityConfig; field skipped.',
          );
          return const SizedBox.shrink();
        }
        return MultiSelectFieldWidget(
          multiSelectFormFieldModel: multiSelectFormField,
          fieldIconSize: widget.fieldIconSize,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          fieldTextStyle: widget.fieldTextStyle,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          height: widget.fieldHeight,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          fieldContentPadding: widget.fieldContentPadding,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          fieldHintStyle: widget.fieldHintStyle,
          opacity: widget.dropdownFieldOpacity,
          showValidationMessage: widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (value) {
            if (multiSelectFormField.key?.isNotEmpty ?? false) {
              widget.onChanged(multiSelectFormField.key!, value);
            }
          },
        );
      case FormFieldType.dynamicMultiselect:
        return _buildDynamicMultiSelectField(
          widget.fieldModel as DynamicMultiSelectFormFieldModel,
        );
      case FormFieldType.signature:
        final signatureFormFieldModel =
            widget.fieldModel as SignatureFormFieldModel;
        return SignatureFieldWidget(
          signatureFormFieldModel: signatureFormFieldModel,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldRadius: widget.fieldRadius,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          readOnlySignatureImageSize: widget.imageFieldSize ?? 200.0,
          fieldFillColor: widget.signatureFieldFillColor ?? Colors.white,
          fieldIconSize: widget.fieldIconSize,
          height: widget.signatureFieldHeight ?? 200.0,
          primaryColor: widget.primaryColor,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          clearSignatureButtonText:
              widget.signatureFieldClearButtonText ?? 'Clear',
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (signatureFile) {
            if (signatureFormFieldModel.key?.isNotEmpty ?? false) {
              widget.onChanged(signatureFormFieldModel.key!, signatureFile);
            }
          },
        );
      case FormFieldType.uploader:
        final uploaderModel = widget.fieldModel as FileUploaderFormFieldModel;
        return FileUploaderFieldWidget(
          fileUploaderFormFieldModel: uploaderModel,
          spacing: widget.spacing,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.uploaderFieldFillColor ?? Colors.white,
          enablePdfAnnotation: widget.uploaderFieldEnablePdfAnnotation,
          pdfAnnotationTexts:
              widget.uploaderFieldPdfAnnotationTexts ??
              const PdfAnnotationTexts(),
          fieldRadius: widget.fieldRadius,
          fieldIconSize: widget.fieldIconSize,
          fieldHintStyle: widget.fieldHintStyle,
          fieldHeight: widget.fieldHeight,
          primaryColor: widget.primaryColor,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          onChanged: (file) {
            if (uploaderModel.key?.isNotEmpty ?? false) {
              widget.onChanged(uploaderModel.key!, file);
            }
          },
        );
      case FormFieldType.takephoto:
        final takePhotoFieldModel =
            widget.fieldModel as TakePhotoFormFieldModel;
        return TakePhotoFieldWidget(
          takePhotoFieldModel: takePhotoFieldModel,
          spacing: widget.spacing,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          fieldRadius: widget.fieldRadius,
          fieldSize: widget.takePhotoFieldSize ?? 200,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          fieldIconSize: widget.fieldIconSize,
          primaryColor: widget.primaryColor,
          imageShape: widget.takePhotoFieldShape ?? ImageShape.circle,
          selectOptionText: widget.takePhotoFieldSelectOptionText ?? 'Select',
          takePhotoText: widget.takePhotoFieldTakePhotoText ?? 'Take Photo',
          chooseFromGalleryText:
              widget.takePhotoFieldChooseFromGalleryText ??
              'Choose From Gallery',
          showValidationMessage:
              widget.showValidationMessageForInputsFieldsOnly,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
          onSelectOrPickPhotoSizeValidationFailed:
              widget.takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed,
          onSelectOrPickPhotoFailed:
              widget.takePhotoFieldOnSelectOrPickPhotoFailed,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          onChanged: (image) {
            if (takePhotoFieldModel.key?.isNotEmpty ?? false) {
              widget.onChanged(takePhotoFieldModel.key!, image);
            }
          },
        );

      /// CALCULATED FIELDS
      case FormFieldType.derivedvalue:
        final derivedModel = widget.fieldModel as DerivedValueFormFieldModel;
        // A derived value configured with default options is picked by the
        // technician, not resolved by the engine, so it renders as a dropdown.
        if (derivedModel.hasSelectableDefault && !widget.readOnly) {
          return _buildDerivedDefaultDropdownField(derivedModel);
        }
        return _buildCalculatedField(
          title: derivedModel.title,
          placeholder: derivedModel.placeholder,
          isRequired: derivedModel.required?.value == true,
          value: widget.readOnly
              ? derivedModel.submittedValue
              : derivedModel.value,
        );
      case FormFieldType.computedvalue:
        final computedModel = widget.fieldModel as ComputedValueFormFieldModel;
        return _buildCalculatedField(
          title: computedModel.title,
          placeholder: computedModel.placeholder,
          isRequired: computedModel.required?.value == true,
          value: widget.readOnly
              ? computedModel.submittedValue
              : computedModel.value,
        );

      /// STATICS FIELDS
      case FormFieldType.progressline:
        final progressLineModel =
            widget.fieldModel as ProgressLineFormFieldModel;
        return ProgressLineFieldWidget(
          progressLineFormFieldModel: progressLineModel,
          spacing: widget.spacing,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          fieldFillColor: widget.fieldFillColor,
          progressLineFieldHeight: widget.progressLineFieldHeight ?? 15.0,
          fieldHintStyle: widget.fieldHintStyle,
          fieldRadius: widget.fieldRadius,
          primaryColor: widget.primaryColor,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
        );
      case FormFieldType.progresscircle:
        final progressCircleModel =
            widget.fieldModel as ProgressCircleFormFieldModel;
        return ProgressCircleFieldWidget(
          progressCircleFormFieldModel: progressCircleModel,
          spacing: widget.spacing,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          fieldFillColor: widget.fieldFillColor,
          progressCircleFieldRadiusSize:
              widget.progressCircleFieldRadiusSize ?? 150.0,
          fieldHintStyle: widget.fieldHintStyle,
          primaryColor: widget.primaryColor,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
        );
      case FormFieldType.header:
        final headerModel = widget.fieldModel as HeaderFormFieldModel;
        return HeaderFieldWidget(
          headerFormFieldModel: headerModel,
          spacing: widget.spacing,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          primaryColor: widget.primaryColor,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
        );
      case FormFieldType.link:
        final linkModel = widget.fieldModel as LinkFormFieldModel;
        return LinkFieldWidget(
          linkFormFieldModel: linkModel,
          spacing: widget.spacing,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
          fieldFillColor: widget.fieldFillColor,
          fieldRadius: widget.fieldRadius,
          fieldIconSize: widget.fieldIconSize,
          fieldHintStyle: widget.fieldHintStyle,
          fieldHeight: widget.fieldHeight,
          fieldTextStyle: widget.fieldTextStyle,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
          primaryColor: widget.primaryColor,
          fieldContentPadding: widget.fieldContentPadding,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
        );
      case FormFieldType.label:
        final labelModel = widget.fieldModel as LabelFormFieldModel;
        return LabelFieldWidget(
          lableFormFieldModel: labelModel,
          spacing: widget.spacing,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          primaryColor: widget.primaryColor,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
        );
      case FormFieldType.image:
        final imageModel = widget.fieldModel as ImageFormFieldModel;
        return ImageFieldWidget(
          imageFormFieldModel: imageModel,
          spacing: widget.spacing,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          innerSpacing: widget.innerSpacing,
          fieldRadius: widget.fieldRadius,
          imageFieldSize: widget.imageFieldSize ?? 200.0,
          imageShape: widget.imageFieldShape ?? ImageShape.rectangle,
          primaryColor: widget.primaryColor,
          crossAxisAlignment: widget.crossAxisAlignment,
          mainAxisAlignment: widget.mainAxisAlignment,
          fieldBorderColor: widget.fieldBorderColor,
          fieldBorderWidth: widget.fieldBorderSize,
        );

      /// STRUCTURE FIELDS
      case FormFieldType.repeatinggroup:
        return _buildRepeatingGroupField(
          widget.fieldModel as RepeatingGroupFormFieldModel,
        );
      case FormFieldType.container:
        final containerFormFieldModel =
            widget.fieldModel as ContainerFormFieldModel;
        return ContainerFieldWidget(
          containerFormFieldModel: containerFormFieldModel,
          scopeFields: widget.scopeFields,
          primaryColor: widget.primaryColor,
          locale: widget.locale,
          spacing: widget.spacing,
          innerSpacing: widget.innerSpacing,
          fieldRadius: widget.fieldRadius,
          fieldFillColor: widget.fieldFillColor,
          fieldBorderSize: widget.fieldBorderSize,
          fieldBorderColor: widget.fieldBorderColor,
          fieldHeight: widget.fieldHeight,
          fieldIconSize: widget.fieldIconSize,
          fieldLabelTextStyle: widget.fieldLabelTextStyle,
          fieldTextStyle: widget.fieldTextStyle,
          fieldHintStyle: widget.fieldHintStyle,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
          onChanged: widget.onChanged,
          fieldContentPadding: widget.fieldContentPadding,
          textAreaFieldMinLine: widget.textAreaFieldMinLine,
          progressLineFieldHeight: widget.progressLineFieldHeight,
          progressCircleFieldRadiusSize: widget.progressCircleFieldRadiusSize,
          imageFieldSize: widget.imageFieldSize,
          imageFieldShape: widget.imageFieldShape,
          dateTimeFieldfirstDateTime: widget.dateTimeFieldfirstDateTime,
          dateTimeFieldlastDateTime: widget.dateTimeFieldlastDateTime,
          dateTimeFieldCancelText: widget.dateTimeFieldCancelText,
          dateTimeFieldConfirmText: widget.dateTimeFieldConfirmText,
          dateTimeFieldOnPickeingDateTimeFailed:
              widget.dateTimeFieldOnPickeingDateTimeFailed,
          radioGroupFieldOptionTextStyle: widget.radioGroupFieldOptionTextStyle,
          radioGroupFieldInActiveColor: widget.radioGroupFieldInActiveColor,
          radioGroupFieldRadioSize: widget.radioGroupFieldRadioSize,
          dropdownFieldOpacity: widget.dropdownFieldOpacity,
          showDropdownFieldPrefixLoading: widget.showDropdownFieldPrefixLoading,
          dynamicDropdownOptionsFetcher: widget.dynamicDropdownOptionsFetcher,
          dynamicDropdownParentValueResolver:
              widget.dynamicDropdownParentValueResolver,
          dynamicDropdownSearchHintText: widget.dynamicDropdownSearchHintText,
          dynamicDropdownRetryButtonText: widget.dynamicDropdownRetryButtonText,
          dynamicDropdownNoResultsText: widget.dynamicDropdownNoResultsText,
          dynamicDropdownLoadFailedText: widget.dynamicDropdownLoadFailedText,
          signatureFieldFillColor: widget.signatureFieldFillColor,
          signatureFieldHeight: widget.signatureFieldHeight,
          signatureFieldClearButtonText: widget.signatureFieldClearButtonText,
          uploaderFieldFillColor: widget.uploaderFieldFillColor,
          uploaderFieldEnablePdfAnnotation:
              widget.uploaderFieldEnablePdfAnnotation,
          uploaderFieldPdfAnnotationTexts:
              widget.uploaderFieldPdfAnnotationTexts,
          takePhotoFieldSize: widget.takePhotoFieldSize,
          takePhotoFieldSelectOptionText: widget.takePhotoFieldSelectOptionText,
          takePhotoFieldTakePhotoText: widget.takePhotoFieldTakePhotoText,
          takePhotoFieldChooseFromGalleryText:
              widget.takePhotoFieldChooseFromGalleryText,
          takePhotoFieldShape: widget.takePhotoFieldShape,
          takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed:
              widget.takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed,
          takePhotoFieldOnSelectOrPickPhotoFailed:
              widget.takePhotoFieldOnSelectOrPickPhotoFailed,
          showValidationMessageForInputsFieldsOnly:
              widget.showValidationMessageForInputsFieldsOnly,
          isReadOnly: widget.readOnly,
          isEditMode: widget.isEditMode,
        );
      default:
        PackageLogger.warning(
          'Unknown form field type: ${widget.fieldModel?.type}',
        );
        return const SizedBox.shrink();
    }
  }

  Widget _buildDynamicDropdownField(
    DynamicDropdownFormFieldModel dynamicDropdownFormField,
  ) {
    // Read-only rendering shows the submitted value and needs no fetcher.
    if (widget.dynamicDropdownOptionsFetcher == null && !widget.readOnly) {
      PackageLogger.warning(
        'Dynamic dropdown "${dynamicDropdownFormField.key}" skipped: no '
        'dynamicDropdownOptionsFetcher provided.',
      );
      return const SizedBox.shrink();
    }
    final parentValue = _resolveParentValue(
      dynamicDropdownFormField.entityConfig?.dependsOn?.parentFieldKey,
    );
    return DynamicDropdownFieldWidget(
      dynamicDropdownFormFieldModel: dynamicDropdownFormField,
      optionsFetcher: widget.dynamicDropdownOptionsFetcher,
      parentValue: parentValue,
      // Properties the derived fields of this scope read from the selection,
      // requested with the options so they stay available offline.
      includeProperties: FormFieldScopeUtils.derivedSourceProperties(
        fieldKey: dynamicDropdownFormField.key,
        scope: widget.scopeFields ?? const [],
      ),
      fieldIconSize: widget.fieldIconSize,
      fieldBorderColor: widget.fieldBorderColor,
      fieldBorderWidth: widget.fieldBorderSize,
      fieldFillColor: widget.fieldFillColor,
      fieldLabelTextStyle: widget.fieldLabelTextStyle,
      fieldRadius: widget.fieldRadius,
      fieldTextStyle: widget.fieldTextStyle,
      spacing: widget.spacing,
      innerSpacing: widget.innerSpacing,
      height: widget.fieldHeight,
      isReadOnly: widget.readOnly,
      isEditMode: widget.isEditMode,
      primaryColor: widget.primaryColor,
      fieldContentPadding: widget.fieldContentPadding,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      fieldHintStyle: widget.fieldHintStyle,
      opacity: widget.dropdownFieldOpacity,
      showValidationMessage: widget.showValidationMessageForInputsFieldsOnly,
      searchHintText: widget.dynamicDropdownSearchHintText ?? 'Search',
      retryButtonText: widget.dynamicDropdownRetryButtonText ?? 'Retry',
      noResultsText: widget.dynamicDropdownNoResultsText ?? 'No results',
      loadFailedText:
          widget.dynamicDropdownLoadFailedText ?? 'Failed to load options',
      onChanged: (value) {
        if (dynamicDropdownFormField.key?.isNotEmpty ?? false) {
          widget.onChanged(dynamicDropdownFormField.key!, value);
        }
      },
    );
  }

  Widget _buildDynamicMultiSelectField(
    DynamicMultiSelectFormFieldModel dynamicMultiSelectFormField,
  ) {
    // Read-only rendering shows the submitted value and needs no fetcher.
    if (widget.dynamicDropdownOptionsFetcher == null && !widget.readOnly) {
      PackageLogger.warning(
        'Dynamic multi-select "${dynamicMultiSelectFormField.key}" skipped: '
        'no dynamicDropdownOptionsFetcher provided.',
      );
      return const SizedBox.shrink();
    }
    final parentValue = _resolveParentValue(
      dynamicMultiSelectFormField.entityConfig?.dependsOn?.parentFieldKey,
    );
    return DynamicMultiSelectFieldWidget(
      dynamicMultiSelectFormFieldModel: dynamicMultiSelectFormField,
      optionsFetcher: widget.dynamicDropdownOptionsFetcher,
      parentValue: parentValue,
      fieldIconSize: widget.fieldIconSize,
      fieldBorderColor: widget.fieldBorderColor,
      fieldBorderWidth: widget.fieldBorderSize,
      fieldFillColor: widget.fieldFillColor,
      fieldLabelTextStyle: widget.fieldLabelTextStyle,
      fieldRadius: widget.fieldRadius,
      fieldTextStyle: widget.fieldTextStyle,
      spacing: widget.spacing,
      innerSpacing: widget.innerSpacing,
      height: widget.fieldHeight,
      isReadOnly: widget.readOnly,
      isEditMode: widget.isEditMode,
      primaryColor: widget.primaryColor,
      fieldContentPadding: widget.fieldContentPadding,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      fieldHintStyle: widget.fieldHintStyle,
      opacity: widget.dropdownFieldOpacity,
      showValidationMessage: widget.showValidationMessageForInputsFieldsOnly,
      searchHintText: widget.dynamicDropdownSearchHintText ?? 'Search',
      retryButtonText: widget.dynamicDropdownRetryButtonText ?? 'Retry',
      noResultsText: widget.dynamicDropdownNoResultsText ?? 'No results',
      loadFailedText:
          widget.dynamicDropdownLoadFailedText ?? 'Failed to load options',
      onChanged: (value) {
        if (dynamicMultiSelectFormField.key?.isNotEmpty ?? false) {
          widget.onChanged(dynamicMultiSelectFormField.key!, value);
        }
      },
    );
  }

  /// Renders a derived value whose default is chosen from a static list.
  ///
  /// The options are primitives, so they are wrapped in the label/value shape
  /// the shared dropdown renders and unwrapped again on change: the field keeps
  /// submitting the plain value the contract expects.
  Widget _buildDerivedDefaultDropdownField(
    DerivedValueFormFieldModel derivedModel,
  ) {
    final options = derivedModel.derivedConfig!.defaultValueOptions!;

    return DropdownFieldWidget(
      dropdownFormFieldModel: DropdownFormFieldModel(
        key: derivedModel.key,
        type: FormFieldType.dropdown,
        title: derivedModel.title,
        placeholder: derivedModel.placeholder,
        required: derivedModel.required,
        css: derivedModel.css,
        queryKey: DerivedDefaultValueOptionsModel.staticQueryKey,
        data: options.options,
        value: options.optionOf(derivedModel.value),
      ),
      fieldIconSize: widget.fieldIconSize,
      fieldBorderColor: widget.fieldBorderColor,
      fieldBorderWidth: widget.fieldBorderSize,
      fieldFillColor: widget.fieldFillColor,
      fieldLabelTextStyle: widget.fieldLabelTextStyle,
      fieldRadius: widget.fieldRadius,
      fieldTextStyle: widget.fieldTextStyle,
      spacing: widget.spacing,
      innerSpacing: widget.innerSpacing,
      height: widget.fieldHeight,
      isEditMode: widget.isEditMode,
      primaryColor: widget.primaryColor,
      fieldContentPadding: widget.fieldContentPadding,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      fieldHintStyle: widget.fieldHintStyle,
      opacity: widget.dropdownFieldOpacity,
      showValidationMessage: widget.showValidationMessageForInputsFieldsOnly,
      onChanged: (option) {
        if (derivedModel.key?.isEmpty ?? true) return;
        widget.onChanged(
          derivedModel.key!,
          option[DerivedDefaultValueOptionsModel.optionValueKey],
        );
      },
    );
  }

  Widget _buildCalculatedField({
    required String? title,
    required String? placeholder,
    required bool isRequired,
    required Object? value,
  }) => CalculatedValueFieldWidget(
    title: title,
    placeholder: placeholder,
    isRequired: isRequired,
    displayValue: FormCalculationUtils.formatValue(value),
    spacing: widget.spacing,
    innerSpacing: widget.innerSpacing,
    fieldRadius: widget.fieldRadius,
    fieldFillColor: widget.fieldFillColor,
    fieldBorderWidth: widget.fieldBorderSize,
    fieldBorderColor: widget.fieldBorderColor,
    fieldHeight: widget.fieldHeight,
    fieldLabelTextStyle: widget.fieldLabelTextStyle,
    fieldTextStyle: widget.fieldTextStyle,
    fieldHintStyle: widget.fieldHintStyle,
    fieldContentPadding: widget.fieldContentPadding,
    mainAxisAlignment: widget.mainAxisAlignment,
    crossAxisAlignment: widget.crossAxisAlignment,
  );

  Widget _buildRepeatingGroupField(RepeatingGroupFormFieldModel groupModel) {
    final groupKey = groupModel.key;
    if (groupKey?.isEmpty ?? true) {
      PackageLogger.warning('Repeating group without a key skipped.');
      return const SizedBox.shrink();
    }

    return RepeatingGroupFieldWidget(
      groupFormFieldModel: groupModel,
      isReadOnly: widget.readOnly,
      showValidationMessage:
          widget.showValidationMessageForInputsFieldsOnly ?? false,
      // Each item is its own scope: its fields resolve dependent dropdowns,
      // visibility rules and calculations against that item alone.
      itemFieldBuilder: (field, itemScope, onFieldChanged) =>
          widget.copyForField(
            field,
            // Keyed by the field model itself, so each field keeps its own
            // state while conditional siblings appear and disappear around it,
            // and a definition with duplicate or missing keys still renders.
            key: ObjectKey(field),
            scopeFields: itemScope,
            onChanged: onFieldChanged,
            dynamicDropdownParentValueResolver: (parentFieldKey) =>
                FormFieldScopeUtils.valueByKey(itemScope, parentFieldKey),
            showValidationMessageForInputsFieldsOnly:
                (widget.showValidationMessageForInputsFieldsOnly ?? false) &&
                field is InputFormFieldModel &&
                field.isRequiredWhenVisible &&
                !field.hasValue,
          ),
      onItemFieldChanged: (itemIndex, fieldKey, value) => widget
          .onRepeatingGroupItemFieldChanged
          ?.call(groupKey!, itemIndex, fieldKey, value),
      onAddItem: widget.onRepeatingGroupAddItem == null
          ? null
          : () => widget.onRepeatingGroupAddItem!(groupKey!),
      onDeleteItem: widget.onRepeatingGroupDeleteItem == null
          ? null
          : (itemIndex) =>
                widget.onRepeatingGroupDeleteItem!(groupKey!, itemIndex),
      onItemExpandedChanged: widget.onRepeatingGroupItemExpandedChanged == null
          ? null
          : (itemIndex, isExpanded) => widget
                .onRepeatingGroupItemExpandedChanged!(
                  groupKey!,
                  itemIndex,
                  isExpanded,
                ),
      emptyStateText: widget.repeatingGroupEmptyStateText ?? 'No items yet',
      addItemText: widget.repeatingGroupAddItemText ?? 'Add item',
      itemLabelText: widget.repeatingGroupItemLabelText ?? 'Item',
      deleteItemText: widget.repeatingGroupDeleteItemText ?? 'Delete',
      editItemText: widget.repeatingGroupEditItemText ?? 'Edit',
      maxItemsReachedText:
          widget.repeatingGroupMaxItemsReachedText ??
          'Maximum number of items reached',
      minItemsRequiredText:
          widget.repeatingGroupMinItemsRequiredText ??
          'Please add the required items',
      primaryColor: widget.primaryColor,
      locale: widget.locale,
      spacing: widget.spacing,
      innerSpacing: widget.innerSpacing,
      fieldRadius: widget.fieldRadius,
      fieldFillColor: widget.fieldFillColor,
      fieldBorderSize: widget.fieldBorderSize,
      fieldBorderColor: widget.fieldBorderColor,
      fieldIconSize: widget.fieldIconSize,
      fieldLabelTextStyle: widget.fieldLabelTextStyle,
      fieldTextStyle: widget.fieldTextStyle,
      fieldHintStyle: widget.fieldHintStyle,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
    );
  }

  /// Selected id of the dropdown a dependent field points at, or null when the
  /// field has no parent or the parent has no selection yet.
  Object? _resolveParentValue(String? parentFieldKey) {
    if (parentFieldKey?.isEmpty ?? true) return null;
    final rawParentValue = widget.dynamicDropdownParentValueResolver?.call(
      parentFieldKey!,
    );
    // The backend expects the parent's id, not the full selection map.
    return rawParentValue is Map ? rawParentValue['id'] : rawParentValue;
  }
}
