part of '../../../../omni_core.dart';

class ProgressLineFormFieldModel extends StaticFormFieldModel {
  bool isStatic = true;
  num? data;
  num? maxValue;
  num? minValue;

  ProgressLineFormFieldModel({
    this.data,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
    this.maxValue = 100,
    this.minValue = 0,
  });

  ProgressLineFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(json) {
    data = AppBaseModel.parseNum(json?['data']);
    maxValue = AppBaseModel.parseNum(json?['maxValue']);
    minValue = AppBaseModel.parseNum(json?['minValue']);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['data'] = data;
    json['maxValue'] = maxValue;
    json['minValue'] = minValue;
    return json;
  }
}
