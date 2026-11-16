part of '../../../../omni_core.dart';

/// Multi-select whose options are embedded in the form definition
/// (`data.queryKey: "static"`).
///
/// Its [value] is the list of selected option maps (`{ label, value }`), i.e.
/// the shape the options themselves are declared in, mirroring how
/// [DropdownFormFieldModel] keeps its single selection.
class MultiSelectFormFieldModel
    extends InputFormFieldModel<List<Map<String, dynamic>>?, List<String>?> {
  List<Map<String, dynamic>>? data;
  String? queryKey;

  /// Key of an option holding its submitted value; also its identity when
  /// comparing selections.
  static const String optionValueKey = 'value';

  /// Key of an option holding its display text.
  static const String optionLabelKey = 'label';

  /// Flag to check if the data is from URL or Static data.
  bool get isFromUrl =>
      (queryKey?.isNotEmpty ?? false) &&
      (queryKey?.toLowerCase().trim() != 'static') &&
      (data?.isEmpty ?? true);

  MultiSelectFormFieldModel({
    this.data,
    this.queryKey,
    super.submittedValue,
    super.value,
    super.key,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  }) : super(type: FormFieldType.multiselect);

  MultiSelectFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(
        json,
        parseSelection(json?['value']),
        parseSubmittedDisplayValues(json?['submittedValue'], optionLabelKey),
      ) {
    data = _parseOptions(json);
    queryKey = AppBaseModel.parseString(json?['data']?['queryKey']);
  }

  /// Options come from `data.data`; `resolvedOptions` is the pre-resolved copy
  /// the backend renders with and is used when the raw list is absent.
  static List<Map<String, dynamic>>? _parseOptions(Map<String, dynamic>? json) {
    final rawData = json?['data']?['data'];
    if (rawData is List) {
      return rawData.whereType<Map<String, dynamic>>().toList();
    }
    final resolvedOptions = json?['resolvedOptions'];
    if (resolvedOptions is List) {
      return resolvedOptions.whereType<Map<String, dynamic>>().toList();
    }
    return null;
  }

  /// A selection is kept as the option maps themselves; entries of any other
  /// shape are ignored, exactly as a single dropdown ignores a non-map value.
  static List<Map<String, dynamic>>? parseSelection(dynamic value) =>
      value is List ? value.whereType<Map<String, dynamic>>().toList() : null;

  /// Submitted values arrive as the list of selected entries: the plain
  /// submitted values for a static multi-select (`["option 1", "option 2"]`)
  /// and the selected option maps for a dynamic one
  /// (`[{ id, displayValue, entityKey }]`). Both are kept as one display text
  /// per selected item, which read-only rendering shows as chips.
  static List<String>? parseSubmittedDisplayValues(
    dynamic submittedValue,
    String nameKey,
  ) {
    if (submittedValue == null) return null;
    final entries = _submittedEntries(submittedValue, nameKey);
    final displayValues = entries
        .map(
          (entry) => entry is Map
              ? _entryDisplayValue(entry, nameKey)
              : AppBaseModel.parseString(entry)?.trim(),
        )
        .whereType<String>()
        .where((displayValue) => displayValue.isNotEmpty)
        .toList();
    if (displayValues.length != entries.length) {
      PackageLogger.warning(
        'MultiSelect submitted value: ${entries.length - displayValues.length} '
        'of ${entries.length} selected entries carry no display text.',
      );
    }
    return displayValues.isEmpty ? null : displayValues;
  }

  /// The selected entries of a submitted value.
  ///
  /// A selection normally arrives as a list, but one that reached the backend
  /// serialized into a single text comes back as that text
  /// (`"[option 1, option 2]"`), which is split back into its entries so a
  /// read-only field still shows one item at a time instead of the whole
  /// serialized selection.
  static List<dynamic> _submittedEntries(
    dynamic submittedValue,
    String nameKey,
  ) {
    if (submittedValue is List) return submittedValue;
    if (submittedValue is String) {
      final entries = _parseSerializedSelection(submittedValue, nameKey);
      if (entries != null) return entries;
    }
    return [submittedValue];
  }

  /// Entries of a selection serialized into one text, or `null` when the text
  /// is not a serialized selection and is therefore one submitted value.
  static List<dynamic>? _parseSerializedSelection(
    String submittedValue,
    String nameKey,
  ) {
    final serialized = submittedValue.trim();
    if (!serialized.startsWith('[') || !serialized.endsWith(']')) return null;

    final decodedEntries = _decodeJsonSelection(serialized);
    if (decodedEntries != null) return decodedEntries;

    final items = serialized
        .substring(1, serialized.length - 1)
        .split(',')
        .map((item) => item.replaceAll('{', '').replaceAll('}', '').trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.isEmpty) return const [];

    // Only a selection whose grouped entries carry display text is read back as
    // entries; anything else is a plain list of submitted values, which may
    // legitimately contain a colon.
    final entries = _groupSerializedEntries(items);
    final hasDisplayText =
        entries?.any((entry) => _entryDisplayValue(entry, nameKey) != null) ??
        false;
    return hasDisplayText ? entries : items;
  }

  static List<dynamic>? _decodeJsonSelection(String serialized) {
    try {
      final decoded = jsonDecode(serialized);
      return decoded is List ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  /// Rebuilds the `key: value` texts of a serialized selection into one map per
  /// selected entry, where a repeated key starts the next entry. Returns `null`
  /// as soon as an item is not a `key: value` pair, i.e. the selection holds
  /// plain submitted values rather than option maps.
  static List<Map<String, dynamic>>? _groupSerializedEntries(
    List<String> items,
  ) {
    final entries = <Map<String, dynamic>>[];
    var entry = <String, dynamic>{};
    for (final item in items) {
      final separatorIndex = item.indexOf(':');
      if (separatorIndex <= 0) return null;
      final key = item.substring(0, separatorIndex).trim();
      if (key.isEmpty) return null;
      if (entry.containsKey(key)) {
        entries.add(entry);
        entry = <String, dynamic>{};
      }
      entry[key] = item.substring(separatorIndex + 1).trim();
    }
    if (entry.isNotEmpty) entries.add(entry);
    return entries.isEmpty ? null : entries;
  }

  /// Display text of one selected entry. [nameKey] is tried first, then the
  /// keys of the other multi-select shape, so a dynamic selection still reads
  /// correctly when its field definition arrives without an `entityConfig` and
  /// is therefore parsed as a static one.
  static String? _entryDisplayValue(Map entry, String nameKey) {
    final displayKeys = <String>{
      nameKey,
      optionLabelKey,
      DynamicMultiSelectFormFieldModel.optionDisplayValueKey,
      optionValueKey,
    };
    for (final displayKey in displayKeys) {
      final displayValue = AppBaseModel.parseString(entry[displayKey])?.trim();
      if (displayValue?.isNotEmpty ?? false) return displayValue;
    }
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['data'] = data;
    json['queryKey'] = queryKey;
    return json;
  }
}
