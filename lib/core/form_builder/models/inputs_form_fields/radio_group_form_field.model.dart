part of '../../../../omni_core.dart';

class RadioGroupFormFieldModel extends InputFormFieldModel<String?, String?> {
  List<Map<String, dynamic>>? data;

  RadioGroupFormFieldModel({
    this.data,
    super.value,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  RadioGroupFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseString(json?['value']),
        AppBaseModel.parseString(json?['submittedValue']),
      ) {
    final rawData = json?['data'];
    if (rawData is List) {
      data = rawData.whereType<Map<String, dynamic>>().toList();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['data'] = data;
    return json;
  }
}
