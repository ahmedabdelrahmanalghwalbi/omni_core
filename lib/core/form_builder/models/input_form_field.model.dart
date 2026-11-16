part of '../../../omni_core.dart';

/// Base for all INPUT type fields
abstract class InputFormFieldModel<T, M> extends FormFieldModel {
  T? value;
  M? submittedValue;

  InputFormFieldModel({
    super.key,
    super.type,
    super.title,
    super.placeholder,
    super.required,
    super.css,
    this.value,
    this.submittedValue,
  });

  InputFormFieldModel.fromJson(
    super.json,
    T? parsedValue,
    M? parsedSubmittedValue,
  ) : value = parsedValue,
      submittedValue = parsedSubmittedValue,
      super.fromJson();

  /// Whether the field currently holds a value, i.e. whether a `required`
  /// field is satisfied. Empty texts and empty collections (multi-selects,
  /// multiple photos) count as no value.
  bool get hasValue {
    final currentValue = value;
    if (currentValue == null) return false;
    if (currentValue is String) return currentValue.isNotEmpty;
    if (currentValue is Iterable) return currentValue.isNotEmpty;
    if (currentValue is Map) return currentValue.isNotEmpty;
    return true;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['value'] = value;
    return json;
  }
}
