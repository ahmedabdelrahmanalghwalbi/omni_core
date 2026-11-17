part of '../../../omni_core.dart';

/// Evaluates `visibilityRules` within one scope and clears the values of the
/// fields it hides.
abstract class FormVisibilityUtils {
  /// Guards against a definition whose rules keep toggling each other; a stable
  /// form settles within one or two passes.
  static const int _maxPasses = 10;

  /// Whether [field] is shown, given the current values of its siblings.
  ///
  /// A field with no rule, an incomplete rule, or a rule pointing at a field
  /// outside [scope] is shown: a malformed definition must never silently hide
  /// data the technician entered.
  ///
  /// [useSubmittedValues] reads a submitted form instead of one being filled
  /// in: the rules are then evaluated against what was actually submitted, so
  /// a submission shows the fields that were visible when it was made.
  static bool isVisible(
    FormFieldModel field,
    List<FormFieldModel> scope, {
    bool useSubmittedValues = false,
  }) {
    final rules = field.visibilityRules;
    if (rules == null || !rules.isConditional) return true;

    return rules.evaluate(
      (condition) => _evaluateCondition(
        condition,
        field: field,
        scope: scope,
        useSubmittedValues: useSubmittedValues,
      ),
    );
  }

  /// Compares one condition against the value its controlling sibling holds.
  ///
  /// A condition pointing outside [scope] is met, so a rule referencing an
  /// unknown or cross-scope field never hides data on its own; combined with
  /// `OR` it is also the reading that shows the field.
  static bool _evaluateCondition(
    VisibilityConditionModel condition, {
    required FormFieldModel field,
    required List<FormFieldModel> scope,
    required bool useSubmittedValues,
  }) {
    final controllingField = FormFieldScopeUtils.fieldByKey(
      scope,
      condition.fieldKey,
    );
    if (controllingField == null) {
      PackageLogger.warning(
        'Visibility rule of "${field.key}" references "${condition.fieldKey}", '
        'which is not a sibling in its scope; the condition is treated as met.',
      );
      return true;
    }

    return condition.evaluate(
      _controllingValue(
        controllingField,
        useSubmittedValues: useSubmittedValues,
      ),
    );
  }

  /// The value a condition reads from the field it points at.
  ///
  /// A repeating group holds no value of its own, so what a rule can ask about
  /// it is whether it has items; its items are therefore what the condition
  /// sees, which is what makes `exists`/`notExists` work against a group.
  static Object? _controllingValue(
    FormFieldModel field, {
    required bool useSubmittedValues,
  }) {
    if (field is RepeatingGroupFormFieldModel) return field.items;
    if (field is InputFormFieldModel) {
      return useSubmittedValues ? field.submittedValue : field.value;
    }
    return null;
  }

  /// The fields of [fields] that are currently shown, evaluated against
  /// [scope].
  static List<FormFieldModel> visibleFields(
    List<FormFieldModel> fields,
    List<FormFieldModel> scope, {
    bool useSubmittedValues = false,
  }) => fields
      .where(
        (field) =>
            isVisible(field, scope, useSubmittedValues: useSubmittedValues),
      )
      .toList();

  /// Clears the value of every hidden field in [scope], repeating until nothing
  /// else becomes hidden so a chain such as action -> reason -> reason details
  /// is cleared in full.
  ///
  /// Returns the number of values cleared.
  static int pruneHiddenValues(List<FormFieldModel> scope) {
    var cleared = 0;

    for (var pass = 0; pass < _maxPasses; pass++) {
      var clearedInPass = false;
      for (final field in scope) {
        if (field is! InputFormFieldModel) continue;
        if (field.value == null) continue;
        if (isVisible(field, scope)) continue;
        field.value = null;
        cleared++;
        clearedInPass = true;
      }
      if (!clearedInPass) break;
    }

    return cleared;
  }

  /// Prunes the top-level scope and the scope of every repeating-group item.
  static int pruneForm(List<FormFieldModel>? fields) {
    final topLevelScope = FormFieldScopeUtils.flatten(fields);
    var cleared = pruneHiddenValues(topLevelScope);

    for (final group in FormFieldScopeUtils.groupsOf(topLevelScope)) {
      for (final item in group.items) {
        cleared += pruneHiddenValues(FormFieldScopeUtils.flatten(item.fields));
      }
    }

    return cleared;
  }
}
