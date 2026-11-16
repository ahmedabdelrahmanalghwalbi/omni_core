part of '../../../omni_core.dart';

/// Reads and writes field values inside one scope.
///
/// A scope is the set of fields that see each other: the top-level fields of a
/// form, or the fields of a single repeating-group item. Containers are layout
/// only, so their children belong to the enclosing scope; a repeating group is
/// a scope boundary, so its items are never part of the enclosing one.
abstract class FormFieldScopeUtils {
  /// The fields of [fields] that make up one scope, with containers unwrapped
  /// and repeating groups kept as single entries.
  static List<FormFieldModel> flatten(List<FormFieldModel>? fields) {
    final scope = <FormFieldModel>[];

    void walk(List<FormFieldModel> fieldList) {
      for (final field in fieldList) {
        if (field is ContainerFormFieldModel) {
          walk(field.containerFields ?? const []);
          continue;
        }
        scope.add(field);
      }
    }

    walk(fields ?? const []);
    return scope;
  }

  static FormFieldModel? fieldByKey(List<FormFieldModel> scope, String? key) {
    if (key?.isEmpty ?? true) return null;
    for (final field in scope) {
      if (field.key == key) return field;
    }
    return null;
  }

  /// Current value of [key] in [scope], or `null` when the field is unknown or
  /// holds no value.
  static Object? valueByKey(List<FormFieldModel> scope, String? key) {
    final field = fieldByKey(scope, key);
    return field is InputFormFieldModel ? field.value : null;
  }

  /// Assigns [value] to [key] within [scope]. Returns whether the field exists.
  static bool setValueByKey(
    List<FormFieldModel> scope,
    String? key,
    dynamic value,
  ) {
    final field = fieldByKey(scope, key);
    if (field is! InputFormFieldModel) return false;
    field.value = value;
    return true;
  }

  static List<RepeatingGroupFormFieldModel> groupsOf(
    List<FormFieldModel> scope,
  ) => scope.whereType<RepeatingGroupFormFieldModel>().toList();

  /// The number a value contributes to a calculation, or `null` when it carries
  /// none.
  ///
  /// A selection map contributes its submitted `value` (a static option may
  /// legitimately hold a number); its `id` is an entity identifier and never a
  /// quantity, so it is deliberately not read here.
  static num? numericValue(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    if (value is Map) return numericValue(value['value']);
    return null;
  }

  /// Entity properties the derived fields of [scope] read from the selection of
  /// [fieldKey], so a dropdown can request them with its options and keep them
  /// available offline.
  static List<String> derivedSourceProperties({
    required String? fieldKey,
    required List<FormFieldModel> scope,
  }) {
    if (fieldKey?.isEmpty ?? true) return const [];
    final properties = <String>{};
    for (final field in scope) {
      if (field is! DerivedValueFormFieldModel) continue;
      final config = field.derivedConfig;
      // Not filtered by mode: a field that names a source property needs it
      // whatever else its configuration also carries.
      if (config == null || config.mode == DerivedValueMode.aggregate) continue;
      if (config.sourceField != fieldKey) continue;
      final property = config.sourceProperty;
      if (property?.isNotEmpty ?? false) properties.add(property!);
    }
    return properties.toList();
  }
}
