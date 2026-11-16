part of '../../../../omni_core.dart';

class ContainerFormFieldModel extends StructureFormFieldModel {
  List<FormFieldModel>? containerFields;
  ContainerFormFieldModel({
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
    this.containerFields,
  });
  ContainerFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(json) {
    final List<FormFieldModel> formFields = AppBaseModel.parseList(
      data: json?['container'],
      fromJson: FormFieldModel.getFormFieldByType,
    );
    containerFields = formFields;
  }
}
