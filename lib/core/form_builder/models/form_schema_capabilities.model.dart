part of '../../../omni_core.dart';

/// Which dynamic-engine features a parsed form schema actually uses.
///
/// A schema that uses none of them is rendered exactly as before, so existing
/// forms keep their current behavior without any per-form configuration.
class FormSchemaCapabilities {
  final bool hasRepeatingGroups;
  final bool hasVisibilityRules;
  final bool hasCalculatedFields;

  const FormSchemaCapabilities({
    this.hasRepeatingGroups = false,
    this.hasVisibilityRules = false,
    this.hasCalculatedFields = false,
  });

  /// Whether the schema needs the scope-aware engine (per-item state,
  /// visibility pruning, recalculation) rather than the flat renderer.
  bool get usesDynamicEngine =>
      hasRepeatingGroups || hasVisibilityRules || hasCalculatedFields;

  /// Inspects the whole schema, including container children and the item
  /// template of every repeating group.
  factory FormSchemaCapabilities.detect(List<FormFieldModel>? fields) {
    var hasRepeatingGroups = false;
    var hasVisibilityRules = false;
    var hasCalculatedFields = false;

    void walk(List<FormFieldModel> fieldList) {
      for (final field in fieldList) {
        if (field.visibilityRules?.isConditional ?? false) {
          hasVisibilityRules = true;
        }
        switch (field) {
          case final RepeatingGroupFormFieldModel group:
            hasRepeatingGroups = true;
            walk(group.templateFields);
          case final ContainerFormFieldModel container:
            walk(container.containerFields ?? const []);
          case DerivedValueFormFieldModel():
          case ComputedValueFormFieldModel():
            hasCalculatedFields = true;
          default:
            break;
        }
      }
    }

    walk(fields ?? const []);

    return FormSchemaCapabilities(
      hasRepeatingGroups: hasRepeatingGroups,
      hasVisibilityRules: hasVisibilityRules,
      hasCalculatedFields: hasCalculatedFields,
    );
  }
}
