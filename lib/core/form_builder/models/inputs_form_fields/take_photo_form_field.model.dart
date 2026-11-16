part of '../../../../omni_core.dart';

class TakePhotoFormFieldModel extends InputFormFieldModel<File?, String?> {
  bool? showPickingOptions;

  TakePhotoFormFieldModel({
    this.showPickingOptions,
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  TakePhotoFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        null,
        AppBaseModel.parseString(json?['submittedValue']),
      ) {
    showPickingOptions = AppBaseModel.parseBool(json?['showPickingOptions']);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['showPickingOptions'] = showPickingOptions;
    return json;
  }
}
