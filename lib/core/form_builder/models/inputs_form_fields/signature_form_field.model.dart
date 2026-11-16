part of '../../../../omni_core.dart';

class SignatureFormFieldModel extends InputFormFieldModel<File?, String?> {
  SignatureFormFieldModel({
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  SignatureFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        null,
        AppBaseModel.parseString(json?['submittedValue']),
      );
}
