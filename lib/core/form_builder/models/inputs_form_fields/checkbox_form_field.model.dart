part of '../../../../omni_core.dart';

class CheckboxFormFieldModel extends InputFormFieldModel<bool?, bool?> {
  CheckboxFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  CheckboxFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseBool(json?['value']),
        AppBaseModel.parseBool(json?['submittedValue']),
      );
}
