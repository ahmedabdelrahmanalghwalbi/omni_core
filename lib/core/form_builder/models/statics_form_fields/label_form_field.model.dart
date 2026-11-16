part of '../../../../omni_core.dart';

class LabelFormFieldModel extends StaticFormFieldModel {
  bool isStatic = true;
  String? data;

  LabelFormFieldModel({
    this.data,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  LabelFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(json) {
    data = AppBaseModel.parseString(json?['data']);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['data'] = data;
    return json;
  }
}
