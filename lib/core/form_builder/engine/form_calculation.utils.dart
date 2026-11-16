part of '../../../omni_core.dart';

/// Resolves derived and computed field values.
///
/// These values are a display convenience for immediate feedback; the server
/// recomputes them on submission and its result is the authoritative one.
abstract class FormCalculationUtils {
  /// A chain resolves in as many passes as it is long; the cap only guards
  /// against a definition whose fields reference each other in a cycle.
  static const int _maxPasses = 10;

  /// Recalculates the whole form.
  ///
  /// A repeating-group item is an isolated scope that reads nothing outside
  /// itself, so the items resolve once and first. The top level then resolves
  /// against them, and its two kinds of value depend on each other in the
  /// definition's direction, not in a fixed one: an aggregate reads the items,
  /// while a formula may in turn read that aggregate — a total of every item
  /// plus a call-out fee, say. Running them in either fixed order leaves one
  /// side reading the other's previous value, so they run together until
  /// nothing changes.
  ///
  /// Returns whether any value changed, so a caller that also prunes hidden
  /// fields knows whether the form still needs another round.
  static bool recalculateForm(List<FormFieldModel>? fields) {
    final topLevelScope = FormFieldScopeUtils.flatten(fields);
    var changedAny = false;

    for (final group in FormFieldScopeUtils.groupsOf(topLevelScope)) {
      for (final item in group.items) {
        if (recalculateScope(FormFieldScopeUtils.flatten(item.fields))) {
          changedAny = true;
        }
      }
    }

    for (var pass = 0; pass < _maxPasses; pass++) {
      // Aggregates first: a formula reading one must see the value of the
      // items as they are now, not as they were before the last edit.
      final aggregatesChanged = recalculateAggregates(topLevelScope);
      final scopeChanged = recalculateScope(topLevelScope);
      if (!aggregatesChanged && !scopeChanged) return changedAny;
      changedAny = true;
    }

    PackageLogger.warning(
      'Top-level calculated values did not settle within $_maxPasses passes; '
      'the definition likely has fields that reference each other in a cycle.',
    );
    return changedAny;
  }

  /// Resolves the lookup, formula and computed fields of one scope, repeating
  /// until the values stabilize so chains such as
  /// `subtotal -> additional -> total` settle in one call.
  ///
  /// Returns whether any value changed, so a caller resolving several scopes
  /// against each other knows whether they have settled.
  static bool recalculateScope(List<FormFieldModel> scope) {
    var changedAny = false;

    for (var pass = 0; pass < _maxPasses; pass++) {
      var changed = false;

      for (final field in scope) {
        final Object? nextValue;
        switch (field) {
          case final DerivedValueFormFieldModel derived:
            if (!(derived.derivedConfig?.isConstant ?? false) &&
                derived.derivedConfig?.mode == DerivedValueMode.aggregate) {
              continue;
            }
            nextValue = FormVisibilityUtils.isVisible(derived, scope)
                ? _resolveDerived(derived, scope)
                : null;
          case final ComputedValueFormFieldModel computed:
            nextValue = FormVisibilityUtils.isVisible(computed, scope)
                ? _resolveComputed(computed, scope)
                : null;
          default:
            continue;
        }

        final calculatedField = field as InputFormFieldModel;
        if (calculatedField.value == nextValue) continue;
        if (nextValue == null && calculatedField.value != null) {
          PackageLogger.warning(
            'Calculated field "${field.key}" went blank. '
            '${_blankDiagnostic(field, scope)}',
          );
        }
        calculatedField.value = nextValue;
        changed = true;
      }

      if (!changed) return changedAny;
      changedAny = true;
    }

    PackageLogger.warning(
      'Calculated values did not settle within $_maxPasses passes; the '
      'definition likely has fields that reference each other in a cycle.',
    );
    return changedAny;
  }

  /// Resolves the top-level derived fields that reduce one child field across
  /// all the items of a repeating group.
  ///
  /// Returns whether any of them changed, which is what lets [recalculateForm]
  /// settle the aggregates and the formulas reading them against each other.
  static bool recalculateAggregates(List<FormFieldModel> topLevelScope) {
    var changed = false;

    for (final field in topLevelScope) {
      if (field is! DerivedValueFormFieldModel) continue;
      final config = field.derivedConfig;
      if (config == null || config.mode != DerivedValueMode.aggregate) continue;
      // A constant carries its own value; the item scan would blank it.
      if (config.isConstant) continue;

      final nextValue = FormVisibilityUtils.isVisible(field, topLevelScope)
          ? _resolveAggregate(field, config, topLevelScope)
          : null;

      if (field.value == nextValue) continue;
      field.value = nextValue;
      changed = true;
    }

    return changed;
  }

  /// Reduces the [config]-named child field across every item of the group it
  /// references.
  ///
  /// Only the items where that child is visible contribute: an item whose
  /// total is hidden — a repair still under warranty, say — is part of the
  /// group but not of the sum.
  static Object? _resolveAggregate(
    DerivedValueFormFieldModel field,
    DerivedValueConfigModel config,
    List<FormFieldModel> topLevelScope,
  ) {
    final group = FormFieldScopeUtils.fieldByKey(
      topLevelScope,
      config.groupField,
    );
    if (group is! RepeatingGroupFormFieldModel) {
      PackageLogger.warning(
        'Aggregate "${field.key}" references "${config.groupField}", which '
        'is not a repeating group in the same scope.',
      );
      return field.defaultValue;
    }

    final values = <num>[];
    for (final item in group.items) {
      final itemScope = FormFieldScopeUtils.flatten(item.fields);
      final childField = FormFieldScopeUtils.fieldByKey(
        itemScope,
        config.childField,
      );
      if (childField is! InputFormFieldModel) continue;
      if (!FormVisibilityUtils.isVisible(childField, itemScope)) continue;
      final value = FormFieldScopeUtils.numericValue(childField.value);
      if (value != null) values.add(value);
    }

    // An empty group, or one whose items are still blank, aggregates to the
    // configured default rather than to zero.
    return values.isEmpty
        ? field.defaultValue
        : apply(config.operator ?? CalculationOperator.sum, values);
  }

  /// Combines [values] with [operator], or `null` when the combination has no
  /// defined result (an empty operand list, or a division by zero).
  static num? apply(CalculationOperator operator, List<num> values) {
    if (values.isEmpty) return null;

    switch (operator) {
      case CalculationOperator.add:
      case CalculationOperator.sum:
        return values.reduce((total, value) => total + value);
      case CalculationOperator.subtract:
        return values.reduce((total, value) => total - value);
      case CalculationOperator.multiply:
      case CalculationOperator.product:
        return values.reduce((total, value) => total * value);
      case CalculationOperator.divide:
        var result = values.first;
        for (final value in values.skip(1)) {
          if (value == 0) return null;
          result = result / value;
        }
        return result;
      case CalculationOperator.min:
        return values.reduce((lowest, value) => value < lowest ? value : lowest);
      case CalculationOperator.max:
        return values.reduce(
          (highest, value) => value > highest ? value : highest,
        );
      case CalculationOperator.avg:
        return values.reduce((total, value) => total + value) / values.length;
    }
  }

  /// A calculated number as display text, without the trailing zeros of a whole
  /// amount.
  static String formatValue(Object? value) {
    if (value == null) return '';
    final number = FormFieldScopeUtils.numericValue(value);
    if (number == null) return value.toString();
    if (number is int || number == number.roundToDouble()) {
      return number.round().toString();
    }
    return number
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Resolves a derived field from whichever configuration it actually
  /// carries.
  ///
  /// `mode` is the preferred hint, not the only signal: a definition that omits
  /// it, or that carries both a source lookup and a formula, still resolves
  /// instead of silently going blank down the branch its `mode` happened to
  /// name.
  static Object? _resolveDerived(
    DerivedValueFormFieldModel field,
    List<FormFieldModel> scope,
  ) {
    final config = field.derivedConfig;
    if (config == null) return null;

    // A selectable default belongs to the technician: the engine seeds it while
    // the field is empty and then leaves whatever was picked alone.
    if (field.hasSelectableDefault) return field.value ?? field.defaultValue;
    if (config.isConstant) return field.defaultValue;

    return _resolveConfiguredValue(config, scope) ?? field.defaultValue;
  }

  /// The value the field's source, formula or both resolve to, or `null` when
  /// neither can be resolved yet.
  static num? _resolveConfiguredValue(
    DerivedValueConfigModel config,
    List<FormFieldModel> scope,
  ) {
    final hasLookup = config.sourceField?.isNotEmpty ?? false;
    final hasFormula = config.operands.isNotEmpty;

    if (config.mode == DerivedValueMode.formula) {
      final formulaValue = _reduceOperands(
        config.operands,
        config.operator,
        scope,
        entityProperty: config.sourceProperty,
      );
      if (formulaValue != null || !hasLookup) return formulaValue;
      return _resolveLookup(config, scope);
    }

    final lookupValue = _resolveLookup(config, scope);
    if (lookupValue != null || !hasFormula) return lookupValue;
    return _reduceOperands(
      config.operands,
      config.operator,
      scope,
      entityProperty: config.sourceProperty,
    );
  }

  /// Reads a property of the entity selected in another field, optionally
  /// combined with a second field.
  static num? _resolveLookup(
    DerivedValueConfigModel config,
    List<FormFieldModel> scope,
  ) {
    if (config.sourceField?.isEmpty ?? true) return null;

    final source = FormFieldScopeUtils.valueByKey(scope, config.sourceField);
    final property = config.sourceProperty;
    final rawValue = (source is Map && (property?.isNotEmpty ?? false))
        ? source[property]
        : source;
    final baseValue = FormFieldScopeUtils.numericValue(rawValue);
    if (baseValue == null) return null;

    final calculation = config.calculation;
    if (calculation == null || !calculation.isEvaluable) return baseValue;

    final operand = FormFieldScopeUtils.numericValue(
      FormFieldScopeUtils.valueByKey(scope, calculation.fieldKey),
    );
    if (operand == null) {
      return _toleratesBlankOperands(calculation.operator!) ? baseValue : null;
    }

    return apply(calculation.operator!, [baseValue, operand]);
  }

  static Object? _resolveComputed(
    ComputedValueFormFieldModel field,
    List<FormFieldModel> scope,
  ) {
    final config = field.computedConfig;
    if (config == null) return null;
    return _reduceOperands(config.operands, config.operator, scope);
  }

  /// Why a calculated field has no value: which of the fields it reads are
  /// missing in its own scope, hidden, or carry nothing numeric.
  static String _blankDiagnostic(
    FormFieldModel field,
    List<FormFieldModel> scope,
  ) {
    final dependencies = switch (field) {
      final DerivedValueFormFieldModel derived =>
        derived.derivedConfig?.scopeDependencies ?? const <String>[],
      final ComputedValueFormFieldModel computed =>
        computed.computedConfig?.operands ?? const <String>[],
      _ => const <String>[],
    };
    if (dependencies.isEmpty) return 'It declares no source fields.';

    final reasons = <String>[];
    for (final dependencyKey in dependencies) {
      final dependency = FormFieldScopeUtils.fieldByKey(scope, dependencyKey);
      if (dependency == null) {
        reasons.add('"$dependencyKey" is not in the same scope');
        continue;
      }
      if (!FormVisibilityUtils.isVisible(dependency, scope)) {
        reasons.add('"$dependencyKey" is hidden');
        continue;
      }
      final value = dependency is InputFormFieldModel
          ? dependency.value
          : null;
      if (value == null) {
        reasons.add('"$dependencyKey" is empty');
        continue;
      }
      if (FormFieldScopeUtils.numericValue(value) == null) {
        final property = field is DerivedValueFormFieldModel
            ? field.derivedConfig?.sourceProperty
            : null;
        reasons.add(
          value is Map && (property?.isNotEmpty ?? false)
              ? '"$dependencyKey" carries no "$property"'
              : '"$dependencyKey" holds no number',
        );
      }
    }

    return reasons.isEmpty ? 'Its sources look complete.' : reasons.join(', ');
  }

  /// Whether [operator] still has a meaningful result when some of its
  /// operands are blank.
  ///
  /// A total that adds up what the technician has entered so far is useful;
  /// a product or a difference with a missing term is not, so those stay blank
  /// until every operand has a value.
  static bool _toleratesBlankOperands(CalculationOperator operator) =>
      switch (operator) {
        CalculationOperator.add ||
        CalculationOperator.sum ||
        CalculationOperator.min ||
        CalculationOperator.max ||
        CalculationOperator.avg => true,
        CalculationOperator.subtract ||
        CalculationOperator.multiply ||
        CalculationOperator.divide ||
        CalculationOperator.product => false,
      };

  /// The number an operand contributes.
  ///
  /// An operand may hold an entity selection rather than a plain number, so a
  /// configured [entityProperty] is read from the selection — that is what lets
  /// a total add a catalog price straight from the field that selected it.
  static num? _operandValue(
    List<FormFieldModel> scope,
    String operandKey,
    String? entityProperty,
  ) {
    final rawValue = FormFieldScopeUtils.valueByKey(scope, operandKey);
    if (rawValue is Map && (entityProperty?.isNotEmpty ?? false)) {
      final propertyValue = FormFieldScopeUtils.numericValue(
        rawValue[entityProperty],
      );
      if (propertyValue != null) return propertyValue;
    }
    return FormFieldScopeUtils.numericValue(rawValue);
  }

  static num? _reduceOperands(
    List<String> operands,
    CalculationOperator? operator,
    List<FormFieldModel> scope, {
    String? entityProperty,
  }) {
    if (operands.isEmpty || operator == null) return null;

    final values = <num>[];
    var hasBlankOperand = false;
    for (final operandKey in operands) {
      final value = _operandValue(scope, operandKey, entityProperty);
      if (value == null) {
        hasBlankOperand = true;
        continue;
      }
      values.add(value);
    }

    if (values.isEmpty) return null;
    if (hasBlankOperand && !_toleratesBlankOperands(operator)) return null;

    return apply(operator, values);
  }
}
