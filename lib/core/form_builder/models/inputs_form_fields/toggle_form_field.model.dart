part of '../../../../omni_core.dart';

class ToggleFormFieldModel extends InputFormFieldModel<bool?, bool?> {
  ToggleFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  }) : super(type: FormFieldType.toggle);

  ToggleFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseBool(json?['value']),
        AppBaseModel.parseBool(json?['submittedValue']),
      );
}
