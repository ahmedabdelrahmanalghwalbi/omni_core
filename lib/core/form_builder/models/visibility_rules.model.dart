part of '../../../omni_core.dart';

/// Comparison used by a single visibility condition.
enum VisibilityOperator {
  equals('equals'),
  notEquals('notEquals'),
  inList('in'),
  notInList('notIn'),
  exists('exists'),
  notExists('notExists');

  const VisibilityOperator(this.apiValue);

  final String apiValue;

  static VisibilityOperator? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase().trim()) {
      case 'equals':
      case 'equal':
      case 'eq':
      case '==':
        return VisibilityOperator.equals;
      case 'notequals':
      case 'not_equals':
      case 'not-equals':
      case 'notequal':
      case 'neq':
      case '!=':
        return VisibilityOperator.notEquals;
      case 'in':
        return VisibilityOperator.inList;
      case 'notin':
      case 'not_in':
      case 'not-in':
        return VisibilityOperator.notInList;
      case 'exists':
        return VisibilityOperator.exists;
      case 'notexists':
      case 'not_exists':
      case 'not-exists':
        return VisibilityOperator.notExists;
      default:
        PackageLogger.warning('Unknown visibility operator: $value');
        return null;
    }
  }
}

/// How the conditions of a [VisibilityRulesModel] combine.
enum VisibilityCombinator {
  and('AND'),
  or('OR');

  const VisibilityCombinator(this.apiValue);

  final String apiValue;

  static VisibilityCombinator? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase().trim()) {
      case 'and':
      case '&&':
        return VisibilityCombinator.and;
      case 'or':
      case '||':
        return VisibilityCombinator.or;
      default:
        PackageLogger.warning('Unknown visibility combinator: $value');
        return null;
    }
  }
}

/// One condition a field's visibility depends on.
///
/// [fieldKey] always refers to a sibling in the same scope: a top-level field
/// reads top-level values, a repeating-group child reads the values of its own
/// item only.
class VisibilityConditionModel {
  final String? fieldKey;
  final VisibilityOperator? operator;

  /// The configured comparison value: a scalar for [VisibilityOperator.equals]
  /// and [VisibilityOperator.notEquals], a list for the membership operators.
  /// The existence operators carry none.
  final dynamic value;

  const VisibilityConditionModel({this.fieldKey, this.operator, this.value});

  factory VisibilityConditionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VisibilityConditionModel();

    try {
      return VisibilityConditionModel(
        fieldKey: AppBaseModel.parseString(json['field']),
        operator: VisibilityOperator.fromString(
          AppBaseModel.parseString(json['operator']),
        ),
        value: json['value'],
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing VisibilityConditionModel: $e',
        stackTrace: s,
      );
      return const VisibilityConditionModel();
    }
  }

  /// Whether the condition can be evaluated at all. An incomplete condition is
  /// treated as "always visible" so a malformed rule never hides data.
  bool get isEvaluable => (fieldKey?.isNotEmpty ?? false) && operator != null;

  /// Evaluates the condition against the controlling field's current value.
  ///
  /// [controllingValue] is the raw value held by the sibling field; a missing
  /// or cleared value is compared as `null`.
  bool evaluate(dynamic controllingValue) {
    if (!isEvaluable) return true;

    final actualValue = comparableValue(controllingValue);

    switch (operator!) {
      // Existence reads the whole value rather than its identity: an empty
      // selection map is unanswered even though it carries no id to compare.
      case VisibilityOperator.exists:
        return hasMeaningfulValue(controllingValue);
      case VisibilityOperator.notExists:
        return !hasMeaningfulValue(controllingValue);
      case VisibilityOperator.equals:
        return _matches(actualValue, value);
      case VisibilityOperator.notEquals:
        return !_matches(actualValue, value);
      case VisibilityOperator.inList:
        return _configuredValues.any(
          (configuredValue) => _matches(actualValue, configuredValue),
        );
      case VisibilityOperator.notInList:
        return !_configuredValues.any(
          (configuredValue) => _matches(actualValue, configuredValue),
        );
    }
  }

  /// Whether a value counts as an answer for [VisibilityOperator.exists] and
  /// [VisibilityOperator.notExists].
  ///
  /// Stricter than a null check, and deliberately the same rule for every kind
  /// of field: a value left at `0`, `false` or blank text has not been answered
  /// yet, and a repeating group with no items holds nothing. The server applies
  /// the same rule when it normalizes a submission, so what the technician sees
  /// is what gets persisted.
  static bool hasMeaningfulValue(Object? value) {
    if (value == null || value == false) return false;
    if (value is num) return value != 0 && !value.isNaN;
    if (value is String) {
      final text = value.trim();
      return text.isNotEmpty && text != '0';
    }
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) {
      // A repeating group is carried as `{ items: [...] }`; it is present only
      // when it actually has items, however many other keys travel with them.
      final items = value['items'];
      if (items is Iterable) return items.isNotEmpty;
      return value.isNotEmpty;
    }
    return true;
  }

  /// The configured values of a membership operator. A scalar is accepted as a
  /// single-entry list so a mis-typed definition still evaluates.
  List<dynamic> get _configuredValues {
    final configuredValue = value;
    if (configuredValue is List) return configuredValue;
    if (configuredValue == null) return const [];
    return [configuredValue];
  }

  /// Compares an actual value with a configured one, tolerating the
  /// string/number mismatch the builder cannot avoid: an entity id arrives as
  /// `49` while the rule that was configured against it may carry `"49"`.
  ///
  /// Two values that both read as numbers are compared numerically, so `49`,
  /// `49.0` and `"49"` are one and the same; anything else is compared as
  /// trimmed text. `null` only ever matches `null`.
  static bool _matches(Object? actualValue, dynamic configuredValue) {
    final expectedValue = comparableValue(configuredValue);
    if (actualValue == null || expectedValue == null) {
      return actualValue == expectedValue;
    }
    if (actualValue == expectedValue) return true;

    final actualNumber = _asNumber(actualValue);
    final expectedNumber = _asNumber(expectedValue);
    if (actualNumber != null && expectedNumber != null) {
      return actualNumber == expectedNumber;
    }

    return actualValue.toString().trim() == expectedValue.toString().trim();
  }

  static num? _asNumber(Object value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value.trim());
    return null;
  }

  /// The value a rule actually compares against.
  ///
  /// Selections are held as maps (`{ id, displayValue, entityKey }` for entity
  /// options, `{ label, value }` for static ones); the rule compares their
  /// identity, never the whole object.
  static Object? comparableValue(dynamic value) {
    if (value is Map) return value['id'] ?? value['value'];
    return value;
  }

  Map<String, dynamic> toJson() => {
    'field': fieldKey,
    'operator': operator?.apiValue,
    // The existence operators carry no comparison value.
    if (value != null) 'value': value,
  };
}

/// Visibility configuration of a single field.
///
/// Two shapes are accepted. The legacy one carries a single `showWhen`
/// condition; the current builder emits a `conditions` list combined by a
/// top-level `AND`/`OR` [combinator], whose entries may themselves be nested
/// condition groups. Both parse into the same structure, so the renderer and
/// the engine only ever see one.
class VisibilityRulesModel {
  final VisibilityCombinator combinator;

  /// The comparisons evaluated directly by this rule.
  final List<VisibilityConditionModel> conditions;

  /// Nested condition groups, each combining its own conditions.
  final List<VisibilityRulesModel> groups;

  VisibilityRulesModel({
    VisibilityConditionModel? showWhen,
    this.combinator = VisibilityCombinator.and,
    List<VisibilityConditionModel> conditions = const [],
    this.groups = const [],
  }) : conditions = showWhen != null ? [showWhen, ...conditions] : conditions;

  factory VisibilityRulesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return VisibilityRulesModel();

    try {
      final conditions = <VisibilityConditionModel>[];
      final groups = <VisibilityRulesModel>[];

      final rawShowWhen = json['showWhen'] != null
          ? AppBaseModel.parseMap(json['showWhen'])
          : null;
      if (rawShowWhen != null) {
        conditions.add(VisibilityConditionModel.fromJson(rawShowWhen));
      }

      final rawConditions = json['conditions'];
      if (rawConditions is List) {
        for (final rawCondition
            in rawConditions.whereType<Map<String, dynamic>>()) {
          if (_isConditionGroup(rawCondition)) {
            groups.add(VisibilityRulesModel.fromJson(rawCondition));
            continue;
          }
          conditions.add(VisibilityConditionModel.fromJson(rawCondition));
        }
      }

      return VisibilityRulesModel(
        combinator:
            VisibilityCombinator.fromString(
              AppBaseModel.parseString(json['operator']),
            ) ??
            VisibilityCombinator.and,
        conditions: conditions,
        groups: groups,
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing VisibilityRulesModel: $e',
        stackTrace: s,
      );
      return VisibilityRulesModel();
    }
  }

  /// An entry of `conditions` is a nested group when it carries conditions of
  /// its own; a leaf carries a `field`/`operator` comparison instead. `operator`
  /// alone does not tell them apart, since both shapes use that key.
  static bool _isConditionGroup(Map<String, dynamic> json) =>
      json['conditions'] is List || json['showWhen'] != null;

  /// The single condition of the legacy shape, kept for callers written against
  /// it. A combined rule reports its first condition.
  VisibilityConditionModel? get showWhen =>
      conditions.isEmpty ? null : conditions.first;

  /// A field with no rules, or with rules that cannot be evaluated, is shown.
  bool get isConditional =>
      conditions.any((condition) => condition.isEvaluable) ||
      groups.any((group) => group.isConditional);

  /// Whether the rule holds.
  ///
  /// Evaluating a condition needs the scope its field is looked up in, which
  /// only the caller knows, so the comparison itself is delegated to
  /// [evaluateCondition]. Conditions that cannot be evaluated are skipped, and
  /// a rule left with nothing to evaluate shows the field.
  bool evaluate(
    bool Function(VisibilityConditionModel condition) evaluateCondition,
  ) {
    final results = <bool>[
      for (final condition in conditions)
        if (condition.isEvaluable) evaluateCondition(condition),
      for (final group in groups)
        if (group.isConditional) group.evaluate(evaluateCondition),
    ];

    if (results.isEmpty) return true;
    return combinator == VisibilityCombinator.or
        ? results.any((isMet) => isMet)
        : results.every((isMet) => isMet);
  }

  /// Every field key this rule reads, including the ones of its nested groups.
  List<String> get referencedFieldKeys => <String>{
    for (final condition in conditions)
      if (condition.fieldKey?.isNotEmpty ?? false) condition.fieldKey!,
    for (final group in groups) ...group.referencedFieldKeys,
  }.toList();

  Map<String, dynamic> toJson() => {
    'operator': combinator.apiValue,
    'conditions': [
      ...conditions.map((condition) => condition.toJson()),
      ...groups.map((group) => group.toJson()),
    ],
  };
}
