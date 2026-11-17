part of '../../../../omni_core.dart';

class DatePickerFieldWidget extends StatelessWidget {
  final DatePickerFormFieldModel dateFormFieldModel;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime?) onChanged;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderWidth;
  final Color fieldBorderColor;
  final double fieldHeight;
  final double fieldIconSize;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final TextStyle? fieldHintStyle;
  final EdgeInsetsGeometry? fieldContentPadding;
  final double spacing;
  final double innerSpacing;
  final bool isReadOnly;
  final bool isEditMode;
  final bool? showValidationMessage;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Color primaryColor;
  final Locale locale;
  final String cancelText;
  final String confirmText;
  final String? invalidDateFormatText;
  final String? outOfRangeDateText;
  final VoidCallback? onPickingDateFailed;

  const DatePickerFieldWidget({
    super.key,
    required this.dateFormFieldModel,
    required this.onChanged,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderWidth,
    required this.fieldBorderColor,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    required this.fieldHeight,
    required this.fieldIconSize,
    required this.spacing,
    required this.innerSpacing,
    required this.primaryColor,
    required this.locale,
    required this.firstDate,
    required this.lastDate,
    required this.cancelText,
    required this.confirmText,
    required this.onPickingDateFailed,
    this.invalidDateFormatText,
    this.outOfRangeDateText,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.fieldHintStyle,
    this.fieldContentPadding,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.showValidationMessage,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(fieldRadius),
      borderSide: BorderSide(color: fieldBorderColor, width: fieldBorderWidth),
    );

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (dateFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: dateFormFieldModel.title!,
              isRequired: dateFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          GestureDetector(
            onTap: isReadOnly
                ? null
                : () async {
                    try {
                      final pickedDate =
                          await DateTimeUtils.showLocaleAdaptiveDatePicker(
                            context: context,
                            initialDate:
                                dateFormFieldModel.value ?? DateTime.now(),
                            firstDate: firstDate,
                            lastDate: lastDate,
                            cancelText: cancelText,
                            confirmText: confirmText,
                            errorFormatText: invalidDateFormatText,
                            errorInvalidText: outOfRangeDateText,
                            textDirection: context.locale.languageCode == 'ar'
                                ? widgets_import.TextDirection.rtl
                                : widgets_import.TextDirection.ltr,
                          );

                      if (pickedDate == null) return;

                      onChanged(pickedDate);
                    } catch (e, s) {
                      PackageLogger.error(
                        'Error picking date',
                        error: e,
                        stackTrace: s,
                      );
                      onPickingDateFailed?.call();
                    }
                  },
            child: AbsorbPointer(
              child: SizedBox(
                height: fieldHeight,
                child: TextFormField(
                  readOnly: true,
                  style: fieldTextStyle,
                  decoration: InputDecoration(
                    hintText: dateFormFieldModel.placeholder,
                    hintStyle: fieldHintStyle,
                    filled: true,
                    fillColor: fieldFillColor,
                    contentPadding:
                        fieldContentPadding ?? const EdgeInsets.all(12),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                    disabledBorder: border,
                    suffixIcon: Icon(
                      Icons.calendar_today_outlined,
                      size: fieldIconSize,
                      color: const Color(0xffBFBFBF),
                    ),
                  ),
                  controller: TextEditingController(
                    text: DateTimeUtils.formatReadableDate(
                      dateTime: isReadOnly
                          ? dateFormFieldModel.submittedValue
                          : dateFormFieldModel.value,
                      locale: locale.languageCode,
                    ),
                  ),
                ),
              ),
            ),
          ),
          FieldValidationMessageWidget(
            requiredValidation: dateFormFieldModel.required,
            showValidationMessage: showValidationMessage,
          ),
        ],
      ),
    );
  }
}
