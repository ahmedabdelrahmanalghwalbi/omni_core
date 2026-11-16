part of '../../../../omni_core.dart';

class DropdownFormFieldModel
    extends InputFormFieldModel<Map<String, dynamic>?, String?> {
  List<Map<String, dynamic>>? data;
  String? queryKey;

  /// Flag to check if the data is from URL or Static data.
  bool get isFromUrl =>
      (queryKey?.isNotEmpty ?? false) &&
      (queryKey?.toLowerCase().trim() != 'static') &&
      (data?.isEmpty ?? true);

  DropdownFormFieldModel({
    this.data,
    this.queryKey,
    super.submittedValue,
    super.value,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  DropdownFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseMap(json?['value']),
        AppBaseModel.parseString(json?['submittedValue']),
      ) {
    final rawData = json?['data']?['data'];
    if (rawData is List) {
      data = rawData.whereType<Map<String, dynamic>>().toList();
    }
    queryKey = AppBaseModel.parseString(json?['data']?['queryKey']);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['data'] = data;
    json['queryKey'] = queryKey;
    return json;
  }
}
