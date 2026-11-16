part of '../../../omni_core.dart';

/// Base for all STRUCTURE (layout) fields like containers, groups
abstract class StructureFormFieldModel extends FormFieldModel {
  StructureFormFieldModel({
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  StructureFormFieldModel.fromJson(super.json) : super.fromJson();
}
