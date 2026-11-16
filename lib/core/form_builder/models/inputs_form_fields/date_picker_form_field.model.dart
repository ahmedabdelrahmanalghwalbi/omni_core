part of '../../../../omni_core.dart';

class DatePickerFormFieldModel
    extends InputFormFieldModel<DateTime?, DateTime?> {
  DatePickerFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  DatePickerFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseDateTime(json?['value']),
        AppBaseModel.parseDateTime(json?['submittedValue']),
      );
}
