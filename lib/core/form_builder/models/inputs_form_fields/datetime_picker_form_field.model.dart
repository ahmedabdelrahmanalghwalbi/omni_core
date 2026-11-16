part of '../../../../omni_core.dart';

class DateTimePickerFormFieldModel
    extends InputFormFieldModel<DateTime?, DateTime?> {
  DateTimePickerFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  DateTimePickerFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseDateTime(json?['value']),
        AppBaseModel.parseDateTime(json?['submittedValue']),
      );
}
