part of '../../../../omni_core.dart';

/// How a [DerivedValueFormFieldModel] obtains its value.
enum DerivedValueMode {
  /// Reads a property of the entity selected in another field, optionally
  /// combined with a second field through `calculation`.
  lookup('lookup'),

  /// Combines the values of other fields in the same scope.
  formula('formula'),

  /// Reduces one child field across all items of a repeating group.
  aggregate('aggregate');

  const DerivedValueMode(this.apiValue);

  final String apiValue;

  static DerivedValueMode? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase().trim()) {
      case 'lookup':
      case 'entity':
      case 'property':
        return DerivedValueMode.lookup;
      case 'formula':
        return DerivedValueMode.formula;
      case 'aggregate':
        return DerivedValueMode.aggregate;
      default:
        PackageLogger.warning('Unknown derived value mode: $value');
        return null;
    }
  }
}

/// The second operand of a lookup-mode derived value, e.g. multiplying the
/// looked-up unit price by a quantity field.
class DerivedCalculationModel {
  final String? fieldKey;
  final CalculationOperator? operator;

  const DerivedCalculationModel({this.fieldKey, this.operator});

  factory DerivedCalculationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DerivedCalculationModel();

    try {
      return DerivedCalculationModel(
        fieldKey: AppBaseModel.parseString(json['field']),
        operator: CalculationOperator.fromString(
          AppBaseModel.parseString(json['operator']),
        ),
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing DerivedCalculationModel: $e',
        stackTrace: s,
      );
      return const DerivedCalculationModel();
    }
  }

  bool get isEvaluable => (fieldKey?.isNotEmpty ?? false) && operator != null;

  Map<String, dynamic> toJson() => {
    'field': fieldKey,
    'operator': operator?.apiValue,
  };
}

/// `derivedConfig.defaultValueOptions` — the choices a derived field offers for
/// its own default value.
///
/// The options are primitives (`[100, 200, 300]`), not label/value objects, and
/// only the static query key is supported; a definition asking for anything
/// else is ignored so the field falls back to a plain read-only value.
class DerivedDefaultValueOptionsModel {
  static const String staticQueryKey = 'static';
  static const String optionLabelKey = 'label';
  static const String optionValueKey = 'value';

  final String? queryKey;
  final List<dynamic> data;

  /// The options as the shape the dropdown widget renders.
  ///
  /// Built once and never rebuilt: the dropdown identifies its selection by
  /// instance, so the list handed to it must be the same one every build.
  final List<Map<String, dynamic>> options;

  DerivedDefaultValueOptionsModel({this.queryKey, List<dynamic>? data})
    : data = data ?? const [],
      options = [
        for (final option in data ?? const [])
          if (option != null)
            {optionLabelKey: option.toString(), optionValueKey: option},
      ];

  factory DerivedDefaultValueOptionsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DerivedDefaultValueOptionsModel();

    try {
      final rawData = json['data'];
      return DerivedDefaultValueOptionsModel(
        queryKey: AppBaseModel.parseString(json['queryKey']),
        data: rawData is List ? List<dynamic>.from(rawData) : const [],
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing DerivedDefaultValueOptionsModel: $e',
        stackTrace: s,
      );
      return DerivedDefaultValueOptionsModel();
    }
  }

  /// Whether the options can actually be offered to the technician.
  bool get isSelectable {
    if (options.isEmpty) return false;
    final key = queryKey?.toLowerCase().trim();
    if (key == null || key.isEmpty || key == staticQueryKey) return true;
    PackageLogger.warning(
      'Derived default options use the unsupported query key "$queryKey"; '
      'the field stays read-only.',
    );
    return false;
  }

  /// Whether every option reads as a number, which makes the field usable as a
  /// numeric operand of another formula.
  bool get isNumeric =>
      data.isNotEmpty &&
      data.every((option) => FormFieldScopeUtils.numericValue(option) != null);

  /// The option carrying [value], or `null` when nothing matches. Matching
  /// tolerates the string/number mismatch a stored draft may carry.
  Map<String, dynamic>? optionOf(Object? value) {
    if (value == null) return null;
    for (final option in options) {
      final optionValue = option[optionValueKey];
      if (optionValue == value) return option;
      if (optionValue.toString().trim() == value.toString().trim()) {
        return option;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'queryKey': queryKey ?? staticQueryKey,
    'data': data,
  };
}

/// `derivedConfig` of a [DerivedValueFormFieldModel].
class DerivedValueConfigModel {
  final DerivedValueMode mode;

  /// Lookup mode: the field holding the selected entity and the property to
  /// read from it.
  final String? sourceField;
  final String? sourceProperty;
  final String? sourceEntityKey;
  final DerivedCalculationModel? calculation;

  /// Formula mode: keys of the fields to combine, in order.
  final List<String> operands;

  /// Aggregate mode: the repeating group and the child field to reduce.
  final String? groupField;
  final String? childField;

  /// Operator of formula and aggregate mode.
  final CalculationOperator? operator;

  /// The value the field falls back to when its configuration resolves to
  /// nothing, and the whole of its value when it carries no other
  /// configuration at all.
  final dynamic defaultValue;

  /// Choices the technician may pick the default value from, which turns the
  /// field into a constant the form owns rather than one the engine derives.
  final DerivedDefaultValueOptionsModel? defaultValueOptions;

  const DerivedValueConfigModel({
    this.mode = DerivedValueMode.lookup,
    this.sourceField,
    this.sourceProperty,
    this.sourceEntityKey,
    this.calculation,
    this.operands = const [],
    this.groupField,
    this.childField,
    this.operator,
    this.defaultValue,
    this.defaultValueOptions,
  });

  factory DerivedValueConfigModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DerivedValueConfigModel();

    try {
      final sourceField = AppBaseModel.parseString(json['sourceField']);
      final groupField = AppBaseModel.parseString(json['groupField']);
      final operands =
          AppBaseModel.parseStringList(json['operands']) ?? const [];
      final rawCalculation = json['calculation'] != null
          ? AppBaseModel.parseMap(json['calculation'])
          : null;
      final rawDefaultOptions = json['defaultValueOptions'] != null
          ? AppBaseModel.parseMap(json['defaultValueOptions'])
          : null;

      return DerivedValueConfigModel(
        mode:
            DerivedValueMode.fromString(
              AppBaseModel.parseString(json['mode']),
            ) ??
            _inferMode(
              groupField: groupField,
              operands: operands,
              sourceField: sourceField,
            ),
        sourceField: sourceField,
        sourceProperty: AppBaseModel.parseString(json['sourceProperty']),
        sourceEntityKey: AppBaseModel.parseString(json['sourceEntityKey']),
        calculation: rawCalculation != null
            ? DerivedCalculationModel.fromJson(rawCalculation)
            : null,
        operands: operands,
        groupField: groupField,
        childField: AppBaseModel.parseString(json['childField']),
        operator: CalculationOperator.fromString(
          AppBaseModel.parseString(json['operator']),
        ),
        defaultValue: json['defaultValue'],
        defaultValueOptions: rawDefaultOptions != null
            ? DerivedDefaultValueOptionsModel.fromJson(rawDefaultOptions)
            : null,
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing DerivedValueConfigModel: $e',
        stackTrace: s,
      );
      return const DerivedValueConfigModel();
    }
  }

  /// A lookup-mode definition carries no explicit `mode`, so the mode is read
  /// from whichever configuration the definition actually provides.
  static DerivedValueMode _inferMode({
    required String? groupField,
    required List<String> operands,
    required String? sourceField,
  }) {
    if (groupField?.isNotEmpty ?? false) return DerivedValueMode.aggregate;
    if (operands.isNotEmpty && (sourceField?.isEmpty ?? true)) {
      return DerivedValueMode.formula;
    }
    return DerivedValueMode.lookup;
  }

  /// Every key this field reads in its own scope.
  ///
  /// Not filtered by [mode]: a definition may carry both a source lookup and a
  /// formula, and the resolver falls back between them, so all referenced keys
  /// count as dependencies.
  List<String> get scopeDependencies => mode == DerivedValueMode.aggregate
      ? const []
      : <String>{
          if (sourceField?.isNotEmpty ?? false) sourceField!,
          if (calculation?.fieldKey?.isNotEmpty ?? false)
            calculation!.fieldKey!,
          ...operands,
        }.toList();

  bool get hasDefaultValue => defaultValue != null;

  /// Whether the technician picks the value from a list instead of the engine
  /// deriving it.
  bool get hasSelectableDefault => defaultValueOptions?.isSelectable ?? false;

  /// Whether the field carries no source, formula or aggregate to resolve, so
  /// its default value is its whole value.
  ///
  /// Selectable defaults are constant by contract: no other configuration is
  /// required alongside them, and any that is present is not resolved.
  bool get isConstant =>
      hasSelectableDefault ||
      (hasDefaultValue &&
          (sourceField?.isEmpty ?? true) &&
          operands.isEmpty &&
          (groupField?.isEmpty ?? true));

  Map<String, dynamic> toJson() => {
    'mode': mode.apiValue,
    'sourceField': sourceField,
    'sourceProperty': sourceProperty,
    'sourceEntityKey': sourceEntityKey,
    'calculation': calculation?.toJson(),
    'operands': operands,
    'groupField': groupField,
    'childField': childField,
    'operator': operator?.apiValue,
    if (hasDefaultValue) 'defaultValue': defaultValue,
    if (defaultValueOptions != null)
      'defaultValueOptions': defaultValueOptions!.toJson(),
  };
}

/// Read-only field whose value the engine derives from other fields: an entity
/// property lookup, a formula over sibling values, or an aggregate over the
/// items of a repeating group.
///
/// Its value is a client-side convenience for immediate feedback; the server
/// recomputes it on submission and its result is the authoritative one.
class DerivedValueFormFieldModel extends InputFormFieldModel<Object?, Object?> {
  DerivedValueConfigModel? derivedConfig;
  bool readOnly;
  String? dataType;

  DerivedValueFormFieldModel({
    this.derivedConfig,
    this.readOnly = true,
    this.dataType,
    super.value,
    super.submittedValue,
    super.key,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  }) : super(type: FormFieldType.derivedvalue);

  DerivedValueFormFieldModel.fromJson(Map<String, dynamic>? json)
    : readOnly = AppBaseModel.parseBool(json?['readOnly']) ?? true,
      dataType = AppBaseModel.parseString(json?['dataType']),
      super.fromJson(json, json?['value'], json?['submittedValue']) {
    final rawDerivedConfig = json?['derivedConfig'] != null
        ? AppBaseModel.parseMap(json?['derivedConfig'])
        : null;
    derivedConfig = rawDerivedConfig != null
        ? DerivedValueConfigModel.fromJson(rawDerivedConfig)
        : null;

    // A list of numeric choices makes the field a numeric operand of any other
    // formula reading it, whether or not the definition said so.
    if ((dataType?.isEmpty ?? true) &&
        (derivedConfig?.defaultValueOptions?.isNumeric ?? false)) {
      dataType = _numberDataType;
    }

    value ??= defaultValue;
  }

  static const String _numberDataType = 'number';

  /// Whether the field's value is a number, so it can be read as an operand and
  /// its default coerced.
  bool get isNumeric =>
      dataType?.toLowerCase().trim() == _numberDataType ||
      (derivedConfig?.defaultValueOptions?.isNumeric ?? false);

  /// Whether the technician picks this field's value from a list rather than
  /// the engine deriving it.
  bool get hasSelectableDefault => derivedConfig?.hasSelectableDefault ?? false;

  /// The configured default, as the type the field renders and submits: a
  /// number when the field is numeric, otherwise the value as configured.
  Object? get defaultValue {
    final configuredValue = derivedConfig?.defaultValue;
    if (configuredValue == null) return null;
    if (!isNumeric) return configuredValue;
    return FormFieldScopeUtils.numericValue(configuredValue) ?? configuredValue;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['readOnly'] = readOnly;
    json['dataType'] = dataType;
    json['derivedConfig'] = derivedConfig?.toJson();
    return json;
  }
}
