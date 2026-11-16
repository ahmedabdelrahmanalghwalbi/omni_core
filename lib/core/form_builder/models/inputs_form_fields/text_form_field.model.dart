part of '../../../../omni_core.dart';

class TextFormFieldModel extends InputFormFieldModel<String?, String?> {
  TextFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  TextFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseString(json?['value']),
        AppBaseModel.parseString(json?['submittedValue']),
      );
}
