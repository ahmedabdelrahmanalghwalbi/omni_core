part of '../../../omni_core.dart';

/// Base for all STATIC (non-input) fields like labels, headers, images
abstract class StaticFormFieldModel extends FormFieldModel {
  StaticFormFieldModel({
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  });

  StaticFormFieldModel.fromJson(super.json) : super.fromJson();
}
