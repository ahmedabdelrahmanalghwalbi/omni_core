part of '../../../../omni_core.dart';

class FileUploaderFormFieldModel extends InputFormFieldModel<File?, String?> {
  List<String>? allowedExtensions;
  bool? isMultiple;
  List<String>? files;

  FileUploaderFormFieldModel({
    this.allowedExtensions,
    this.isMultiple = false,
    this.files,
    super.submittedValue,
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
    super.value,
  });

  FileUploaderFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        null,
        AppBaseModel.parseString(json?['submittedValue']),
      ) {
    allowedExtensions = AppBaseModel.parseStringList(
      json?['allowedExtensions'],
    );
    isMultiple = AppBaseModel.parseBool(json?['multiple']);
    files = AppBaseModel.parseStringList(json?['files']);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['allowedExtensions'] = allowedExtensions;
    json['multiple'] = isMultiple;
    json['files'] = files;
    return json;
  }
}
