part of '../../../../omni_core.dart';

class MultipleTakePhotosFormFieldModel
    extends InputFormFieldModel<List<File>?, String?> {
  bool? showPickingOptions;

  MultipleTakePhotosFormFieldModel({
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

  MultipleTakePhotosFormFieldModel.fromJson(Map<String, dynamic>? json)
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
