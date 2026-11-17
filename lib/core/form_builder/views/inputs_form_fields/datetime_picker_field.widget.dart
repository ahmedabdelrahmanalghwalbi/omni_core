part of '../../../../omni_core.dart';

class DateTimePickerFieldWidget extends StatelessWidget {
  final DateTimePickerFormFieldModel dateTimeFormFieldModel;
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
  final VoidCallback? onPickeingDateTimeFailed;

  const DateTimePickerFieldWidget({
    super.key,
    required this.dateTimeFormFieldModel,
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
    required this.onPickeingDateTimeFailed,
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
          if (dateTimeFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: dateTimeFormFieldModel.title!,
              isRequired: dateTimeFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          GestureDetector(
            onTap: isReadOnly
                ? null
                : () async {
                    try {
                      final initialDate =
                          dateTimeFormFieldModel.value ?? DateTime.now();

                      // Step 1: Pick date
                      final pickedDate =
                          await DateTimeUtils.showLocaleAdaptiveDatePicker(
                            context: context,
                            initialDate: initialDate,
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

                      if (!context.mounted || pickedDate == null) return;

                      // Step 2: Pick time
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(initialDate),
                        cancelText: cancelText,
                        confirmText: confirmText,
                        initialEntryMode: TimePickerEntryMode.input,
                      );

                      if (!context.mounted || pickedTime == null) return;

                      // Combine date and time
                      final selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      onChanged(selectedDateTime);
                    } catch (e, s) {
                      PackageLogger.error(
                        'Error picking date/time',
                        error: e,
                        stackTrace: s,
                      );
                      onPickeingDateTimeFailed?.call();
                    }
                  },
            child: AbsorbPointer(
              child: SizedBox(
                height: fieldHeight,
                child: TextFormField(
                  readOnly: true,
                  style: fieldTextStyle,
                  decoration: InputDecoration(
                    hintText: dateTimeFormFieldModel.placeholder,
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
                    text: DateTimeUtils.formatDateTimeWithAmPm(
                      dateTime: isReadOnly
                          ? dateTimeFormFieldModel.submittedValue
                          : dateTimeFormFieldModel.value,
                      locale: locale.languageCode,
                    ),
                  ),
                ),
              ),
            ),
          ),
          FieldValidationMessageWidget(
            requiredValidation: dateTimeFormFieldModel.required,
            showValidationMessage: showValidationMessage,
          ),
        ],
      ),
    );
  }
}
