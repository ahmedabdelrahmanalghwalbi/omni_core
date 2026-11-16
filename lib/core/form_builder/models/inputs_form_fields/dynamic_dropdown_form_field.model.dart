part of '../../../../omni_core.dart';

/// Dropdown whose options are fetched from a backend entity endpoint
/// (`queryKey: "dynamic"` with an `entityConfig`), optionally depending on
/// the selected value of another dropdown in the same form.
///
/// Its selected [value] is a map of `{ id, displayValue, entityKey }`, which
/// is also the shape submitted to the backend.
class DynamicDropdownFormFieldModel
    extends InputFormFieldModel<Map<String, dynamic>?, String?> {
  DynamicDropdownEntityConfigModel? entityConfig;

  /// Whether this dropdown is enabled only after another dropdown has a value.
  bool get isDependent =>
      entityConfig?.dependsOn?.parentFieldKey?.isNotEmpty ?? false;

  DynamicDropdownFormFieldModel({
    this.entityConfig,
    super.submittedValue,
    super.value,
    super.key,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  }) : super(type: FormFieldType.dynamicDropdown);

  /// The backend sends dynamic dropdowns as `name: "Dropdown"`, so the parsed
  /// [type] stays [FormFieldType.dropdown] and the original [name] is kept for
  /// submission payloads; this class itself is the discriminator.
  DynamicDropdownFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        AppBaseModel.parseMap(json?['value']),
        _parseSubmittedValue(json?['submittedValue']),
      ) {
    final rawEntityConfig = AppBaseModel.parseMap(
      json?['data']?['entityConfig'],
    );
    entityConfig = rawEntityConfig != null
        ? DynamicDropdownEntityConfigModel.fromJson(rawEntityConfig)
        : null;
  }

  /// Submitted values arrive as the selection object
  /// `{ id, displayValue, entityKey }`; read-only rendering shows its
  /// display value only.
  static String? _parseSubmittedValue(dynamic submittedValue) {
    if (submittedValue is Map) {
      return AppBaseModel.parseString(submittedValue['displayValue']);
    }
    return AppBaseModel.parseString(submittedValue);
  }

  /// Whether a raw `Dropdown` field definition is a dynamic dropdown:
  /// `data.queryKey` is `"dynamic"` and `data.entityConfig.entityKey` is set.
  static bool isDynamicDropdownJson(Map<String, dynamic>? json) {
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

/// Backend entity a dynamic dropdown loads its options from.
class DynamicDropdownEntityConfigModel {
  final String? entityKey;
  final String? valueField;
  final String? displayField;
  final DynamicDropdownDependsOnModel? dependsOn;

  DynamicDropdownEntityConfigModel({
    this.entityKey,
    this.valueField,
    this.displayField,
    this.dependsOn,
  });

  factory DynamicDropdownEntityConfigModel.fromJson(
    Map<String, dynamic>? json,
  ) {
    final rawDependsOn = AppBaseModel.parseMap(json?['dependsOn']);
    return DynamicDropdownEntityConfigModel(
      entityKey: AppBaseModel.parseString(json?['entityKey']),
      valueField: AppBaseModel.parseString(json?['valueField']),
      displayField: AppBaseModel.parseString(json?['displayField']),
      dependsOn: rawDependsOn != null
          ? DynamicDropdownDependsOnModel.fromJson(rawDependsOn)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'entityKey': entityKey,
    'valueField': valueField,
    'displayField': displayField,
    'dependsOn': dependsOn?.toJson(),
  };
}

/// Dependency of a dynamic dropdown on another dropdown in the same form.
class DynamicDropdownDependsOnModel {
  final String? relationField;
  final String? parentFieldKey;
  final String? parentEntityKey;

  DynamicDropdownDependsOnModel({
    this.relationField,
    this.parentFieldKey,
    this.parentEntityKey,
  });

  factory DynamicDropdownDependsOnModel.fromJson(Map<String, dynamic>? json) =>
      DynamicDropdownDependsOnModel(
        relationField: AppBaseModel.parseString(json?['relationField']),
        parentFieldKey: AppBaseModel.parseString(json?['parentFieldKey']),
        parentEntityKey: AppBaseModel.parseString(json?['parentEntityKey']),
      );

  Map<String, dynamic> toJson() => {
    'relationField': relationField,
    'parentFieldKey': parentFieldKey,
    'parentEntityKey': parentEntityKey,
  };
}
