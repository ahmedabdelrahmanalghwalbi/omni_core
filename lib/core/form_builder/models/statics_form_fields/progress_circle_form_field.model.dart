part of '../../../../omni_core.dart';

class ProgressCircleFormFieldModel extends StaticFormFieldModel {
  bool isStatic = true;
  num? data;
  num? maxValue;

  ProgressCircleFormFieldModel({
    this.data,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
    this.maxValue = 100,
  });

  ProgressCircleFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(json) {
    data = AppBaseModel.parseNum(json?['data']);
    maxValue = AppBaseModel.parseNum(json?['maxValue']);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['data'] = data;
    json['maxValue'] = maxValue;
    return json;
  }
}
