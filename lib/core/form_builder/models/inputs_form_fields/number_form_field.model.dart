part of '../../../../omni_core.dart';

class NumberFormFieldModel extends InputFormFieldModel<num?, num?> {
  NumberFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  NumberFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseNum(json?['value']),
        AppBaseModel.parseNum(json?['submittedValue']),
      );
}
