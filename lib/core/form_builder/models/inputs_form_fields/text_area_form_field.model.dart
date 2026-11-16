part of '../../../../omni_core.dart';

class TextAreaFormFieldModel extends InputFormFieldModel<String?, String?> {
  TextAreaFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  TextAreaFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseString(json?['value']),
        AppBaseModel.parseString(json?['submittedValue']),
      );
}
