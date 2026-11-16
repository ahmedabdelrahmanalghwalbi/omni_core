part of '../../../../omni_core.dart';

/// `computedConfig` of a [ComputedValueFormFieldModel].
class ComputedValueConfigModel {
  /// Keys of the fields to combine, resolved in the field's own scope.
  final List<String> operands;
  final CalculationOperator? operator;

  const ComputedValueConfigModel({
    this.operands = const [],
    this.operator,
  });

  factory ComputedValueConfigModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ComputedValueConfigModel();

    try {
      return ComputedValueConfigModel(
        operands: AppBaseModel.parseStringList(json['operands']) ?? const [],
        operator: CalculationOperator.fromString(
          AppBaseModel.parseString(json['operator']),
        ),
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing ComputedValueConfigModel: $e',
        stackTrace: s,
      );
      return const ComputedValueConfigModel();
    }
  }

  bool get isEvaluable => operands.isNotEmpty && operator != null;

  Map<String, dynamic> toJson() => {
    'operands': operands,
    'operator': operator?.apiValue,
  };
}

/// Read-only field whose value the engine computes from other fields in the
/// same scope. Like [DerivedValueFormFieldModel] it is a display convenience;
/// the server recomputes it on submission.
class ComputedValueFormFieldModel
    extends InputFormFieldModel<Object?, Object?> {
  ComputedValueConfigModel? computedConfig;
  bool readOnly;
  String? dataType;

  ComputedValueFormFieldModel({
    this.computedConfig,
    this.readOnly = true,
    this.dataType,
    super.value,
    super.submittedValue,
    super.key,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  }) : super(type: FormFieldType.computedvalue);

  ComputedValueFormFieldModel.fromJson(Map<String, dynamic>? json)
    : readOnly = AppBaseModel.parseBool(json?['readOnly']) ?? true,
      dataType = AppBaseModel.parseString(json?['dataType']),
      super.fromJson(json, json?['value'], json?['submittedValue']) {
    final rawComputedConfig = json?['computedConfig'] != null
        ? AppBaseModel.parseMap(json?['computedConfig'])
        : null;
    computedConfig = rawComputedConfig != null
        ? ComputedValueConfigModel.fromJson(rawComputedConfig)
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['readOnly'] = readOnly;
    json['dataType'] = dataType;
    json['computedConfig'] = computedConfig?.toJson();
    return json;
  }
}
