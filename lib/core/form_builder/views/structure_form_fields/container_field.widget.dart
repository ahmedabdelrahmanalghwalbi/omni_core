part of '../../../../omni_core.dart';

class ContainerFieldWidget extends StatelessWidget {
  final ContainerFormFieldModel containerFormFieldModel;

  /// The scope the container's children belong to. A container is layout only,
  /// so its children share the scope of the container itself.
  final List<FormFieldModel>? scopeFields;
  final bool isReadOnly;
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
  final VoidCallback? dateTimeFieldOnPickeingDateTimeFailed;
  final TextStyle? radioGroupFieldOptionTextStyle;
  final Color? radioGroupFieldInActiveColor;
  final double? radioGroupFieldRadioSize;
  final double? dropdownFieldOpacity;
  final bool? showDropdownFieldPrefixLoading;
  final DynamicDropdownOptionsFetcher? dynamicDropdownOptionsFetcher;
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

  const ContainerFieldWidget({
    super.key,
    required this.containerFormFieldModel,
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
    this.isReadOnly = false,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (containerFormFieldModel.containerFields?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (containerFormFieldModel.title?.isNotEmpty ?? false)
            // FieldTitleWithRequiredWidget(
            //   title: containerFormFieldModel.title!,
            //   isRequired: containerFormFieldModel.required?.value == true,
            //   style: fieldLabelTextStyle,
            // ),
            Container(
              padding: EdgeInsets.only(top: spacing),
              decoration: BoxDecoration(
                border: Border.all(
                  color: fieldBorderColor,
                  width: fieldBorderSize,
                ),
                borderRadius: BorderRadius.circular(fieldRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: innerSpacing,
                children:
                    containerFormFieldModel.containerFields
                        ?.map(
                          (field) => FormFieldWidget(
                            fieldModel: field,
                            scopeFields: scopeFields,
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
                            onChanged: onChanged,
                            fieldContentPadding: fieldContentPadding,
                            textAreaFieldMinLine: textAreaFieldMinLine,
                            progressLineFieldHeight: progressLineFieldHeight,
                            progressCircleFieldRadiusSize:
                                progressCircleFieldRadiusSize,
                            imageFieldSize: imageFieldSize,
                            imageFieldShape: imageFieldShape,
                            dateTimeFieldfirstDateTime:
                                dateTimeFieldfirstDateTime,
                            dateTimeFieldlastDateTime:
                                dateTimeFieldlastDateTime,
                            dateTimeFieldCancelText: dateTimeFieldCancelText,
                            dateTimeFieldConfirmText: dateTimeFieldConfirmText,
                            dateTimeFieldOnPickeingDateTimeFailed:
                                dateTimeFieldOnPickeingDateTimeFailed,
                            radioGroupFieldOptionTextStyle:
                                radioGroupFieldOptionTextStyle,
                            radioGroupFieldInActiveColor:
                                radioGroupFieldInActiveColor,
                            radioGroupFieldRadioSize: radioGroupFieldRadioSize,
                            dropdownFieldOpacity: dropdownFieldOpacity,
                            showDropdownFieldPrefixLoading:
                                showDropdownFieldPrefixLoading,
                            dynamicDropdownOptionsFetcher:
                                dynamicDropdownOptionsFetcher,
                            dynamicDropdownParentValueResolver:
                                dynamicDropdownParentValueResolver,
                            dynamicDropdownSearchHintText:
                                dynamicDropdownSearchHintText,
                            dynamicDropdownRetryButtonText:
                                dynamicDropdownRetryButtonText,
                            dynamicDropdownNoResultsText:
                                dynamicDropdownNoResultsText,
                            dynamicDropdownLoadFailedText:
                                dynamicDropdownLoadFailedText,
                            signatureFieldFillColor: signatureFieldFillColor,
                            signatureFieldHeight: signatureFieldHeight,
                            signatureFieldClearButtonText:
                                signatureFieldClearButtonText,
                            uploaderFieldFillColor: uploaderFieldFillColor,
                            uploaderFieldEnablePdfAnnotation:
                                uploaderFieldEnablePdfAnnotation,
                            uploaderFieldPdfAnnotationTexts:
                                uploaderFieldPdfAnnotationTexts,
                            takePhotoFieldSize: takePhotoFieldSize,
                            takePhotoFieldSelectOptionText:
                                takePhotoFieldSelectOptionText,
                            takePhotoFieldTakePhotoText:
                                takePhotoFieldTakePhotoText,
                            takePhotoFieldChooseFromGalleryText:
                                takePhotoFieldChooseFromGalleryText,
                            takePhotoFieldShape: takePhotoFieldShape,
                            takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed:
                                takePhotoFieldOnSelectOrPickPhotoSizeValidationFailed,
                            takePhotoFieldOnSelectOrPickPhotoFailed:
                                takePhotoFieldOnSelectOrPickPhotoFailed,
                            showValidationMessageForInputsFieldsOnly:
                                showValidationMessageForInputsFieldsOnly,
                            readOnly: isReadOnly,
                          ),
                        )
                        .toList() ??
                    [],
              ),
            ),
          FieldValidationMessageWidget(
            requiredValidation: containerFormFieldModel.required,
            showValidationMessage: showValidationMessageForInputsFieldsOnly,
          ),
        ],
      ),
    );
  }
}
