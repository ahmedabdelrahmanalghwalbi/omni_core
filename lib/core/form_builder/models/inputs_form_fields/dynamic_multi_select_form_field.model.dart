part of '../../../../omni_core.dart';

/// Multi-select whose options are fetched from a backend entity endpoint
/// (`queryKey: "dynamic"` with an `entityConfig`), optionally depending on the
/// selected value of another dropdown in the same form.
///
/// Its [value] is the list of selected `{ id, displayValue, entityKey }` maps,
/// which is also the shape submitted to the backend — the multi-selection
/// counterpart of [DynamicDropdownFormFieldModel].
class DynamicMultiSelectFormFieldModel
    extends InputFormFieldModel<List<Map<String, dynamic>>?, List<String>?> {
  DynamicDropdownEntityConfigModel? entityConfig;

  /// Key of an option holding its display text.
  static const String optionDisplayValueKey = 'displayValue';

  /// Key of an option holding its identity.
  static const String optionIdKey = 'id';

  /// Whether this multi-select is enabled only after another dropdown has a
  /// value.
  bool get isDependent =>
      entityConfig?.dependsOn?.parentFieldKey?.isNotEmpty ?? false;

  DynamicMultiSelectFormFieldModel({
    this.entityConfig,
    super.submittedValue,
    super.value,
    super.key,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  }) : super(type: FormFieldType.dynamicMultiselect);

  /// The backend sends dynamic multi-selects as `name: "MultiSelect"`, so the
  /// parsed [type] stays [FormFieldType.multiselect] and the original [name] is
  /// kept for submission payloads; this class itself is the discriminator.
  DynamicMultiSelectFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        MultiSelectFormFieldModel.parseSelection(json?['value']),
        MultiSelectFormFieldModel.parseSubmittedDisplayValues(
          json?['submittedValue'],
          optionDisplayValueKey,
        ),
      ) {
    final rawEntityConfig = AppBaseModel.parseMap(
      json?['data']?['entityConfig'],
    );
    entityConfig = rawEntityConfig != null
        ? DynamicDropdownEntityConfigModel.fromJson(rawEntityConfig)
        : null;
  }

  /// Whether a raw `MultiSelect` field definition is a dynamic one:
  /// `data.queryKey` is `"dynamic"` and `data.entityConfig.entityKey` is set.
  static bool isDynamicMultiSelectJson(Map<String, dynamic>? json) {
    final data = AppBaseModel.parseMap(json?['data']);
    final queryKey = AppBaseModel.parseString(data?['queryKey']);
    final entityKey = AppBaseModel.parseString(
      AppBaseModel.parseMap(data?['entityConfig'])?['entityKey'],
    );
    return queryKey?.toLowerCase().trim() == 'dynamic' &&
        (entityKey?.isNotEmpty ?? false);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['queryKey'] = 'dynamic';
    json['entityConfig'] = entityConfig?.toJson();
    return json;
  }
}
