part of '../../../../omni_core.dart';

/// `groupConfig` of a [RepeatingGroupFormFieldModel]. Everything the group's
/// presentation and item limits are driven by comes from here; nothing about a
/// group is hardcoded by the renderer.
class RepeatingGroupConfigModel {
  final String? groupTitle;
  final String? itemLabel;
  final String? addItemLabel;
  final int minItems;

  /// `null` means the definition sets no upper limit.
  final int? maxItems;
  final bool allowDelete;
  final bool allowEdit;
  final bool collapsibleItems;
  final bool collapseCompletedItems;

  const RepeatingGroupConfigModel({
    this.groupTitle,
    this.itemLabel,
    this.addItemLabel,
    this.minItems = 0,
    this.maxItems,
    this.allowDelete = true,
    this.allowEdit = true,
    this.collapsibleItems = true,
    this.collapseCompletedItems = false,
  });

  factory RepeatingGroupConfigModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RepeatingGroupConfigModel();

    try {
      final minItems = AppBaseModel.parseInt(json['minItems']) ?? 0;
      final maxItems = AppBaseModel.parseInt(json['maxItems']);
      return RepeatingGroupConfigModel(
        groupTitle: AppBaseModel.parseString(json['groupTitle']),
        itemLabel: AppBaseModel.parseString(json['itemLabel']),
        addItemLabel: AppBaseModel.parseString(json['addItemLabel']),
        minItems: minItems < 0 ? 0 : minItems,
        maxItems: (maxItems != null && maxItems > 0) ? maxItems : null,
        allowDelete: AppBaseModel.parseBool(json['allowDelete']) ?? true,
        allowEdit: AppBaseModel.parseBool(json['allowEdit']) ?? true,
        collapsibleItems:
            AppBaseModel.parseBool(json['collapsibleItems']) ?? true,
        collapseCompletedItems:
            AppBaseModel.parseBool(json['collapseCompletedItems']) ?? false,
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing RepeatingGroupConfigModel: $e',
        stackTrace: s,
      );
      return const RepeatingGroupConfigModel();
    }
  }

  Map<String, dynamic> toJson() => {
    'groupTitle': groupTitle,
    'itemLabel': itemLabel,
    'addItemLabel': addItemLabel,
    'minItems': minItems,
    'maxItems': maxItems,
    'allowDelete': allowDelete,
    'allowEdit': allowEdit,
    'collapsibleItems': collapsibleItems,
    'collapseCompletedItems': collapseCompletedItems,
  };
}

/// One entry of a repeating group.
///
/// Every item owns its own field instances, so its values, dependent dropdown
/// options and conditional fields are entirely independent of the other items.
class RepeatingGroupItemModel {
  /// Stable identity of the item for the lifetime of the form, so widgets keep
  /// their state when items above them are removed. It is presentation-only and
  /// is never submitted.
  final String id;

  /// Identifies the item's card in the widget tree.
  ///
  /// Created once per item and never rebuilt: the card must keep the same
  /// element across rebuilds, otherwise every field inside it — an open
  /// dropdown, the text being typed — is torn down on each change. It also
  /// lets a host scroll to the item, e.g. to reveal the one that failed
  /// validation.
  final GlobalKey cardKey;

  final List<FormFieldModel> fields;
  bool isExpanded;

  RepeatingGroupItemModel({
    required this.id,
    required this.fields,
    this.isExpanded = true,
  }) : cardKey = GlobalKey(debugLabel: id);

  /// The item's field carrying [fieldKey], or `null` when the template has no
  /// such field.
  FormFieldModel? fieldByKey(String fieldKey) {
    for (final field in fields) {
      if (field.key == fieldKey) return field;
    }
    return null;
  }
}

/// A group of fields the technician can repeat: maintenance items, inspection
/// findings, or anything else a form administrator configures.
///
/// [templateFields] is the schema of one item and is never bound to a value;
/// each entry of [items] is an independent copy of it.
class RepeatingGroupFormFieldModel extends StructureFormFieldModel {
  RepeatingGroupConfigModel? groupConfig;

  /// The item schema as received, kept so every new item is built by parsing a
  /// fresh copy of it instead of cloning live field models.
  List<Map<String, dynamic>> templateFieldsJson = const [];

  /// The parsed item schema. Used to inspect the group's children (dependency
  /// metadata, navigation entries); it holds no user values.
  List<FormFieldModel> templateFields = const [];

  final List<RepeatingGroupItemModel> items = [];

  int _itemSequence = 0;

  RepeatingGroupFormFieldModel({
    this.groupConfig,
    super.key,
    super.title,
    super.placeholder,
    super.required,
    super.css,
  }) : super(type: FormFieldType.repeatinggroup);

  RepeatingGroupFormFieldModel.fromJson(Map<String, dynamic>? json)
    : super.fromJson(json) {
    final rawGroupConfig = json?['groupConfig'] != null
        ? AppBaseModel.parseMap(json?['groupConfig'])
        : null;
    groupConfig = rawGroupConfig != null
        ? RepeatingGroupConfigModel.fromJson(rawGroupConfig)
        : const RepeatingGroupConfigModel();
    templateFieldsJson = _parseTemplateFieldsJson(json?['fields']);
    templateFields = _buildFields();
    _restoreSubmittedItems(json?['items']);
  }

  /// Reads back the items of a submitted form.
  ///
  /// A submission returns each item as its own `fields` list carrying the
  /// schema plus `submittedValue`, so the items are rebuilt from those lists
  /// and a submitted group renders through exactly the same widgets as a blank
  /// one. Items start collapsed: a read of several items is a summary first.
  void _restoreSubmittedItems(dynamic data) {
    if (data is! List) return;

    final submittedItems = data.whereType<Map<String, dynamic>>().toList()
      ..sort(
        (first, second) => (AppBaseModel.parseInt(first['itemIndex']) ?? 0)
            .compareTo(AppBaseModel.parseInt(second['itemIndex']) ?? 0),
      );

    for (final submittedItem in submittedItems) {
      final itemFields = AppBaseModel.parseList<FormFieldModel>(
        data: submittedItem['fields'],
        fromJson: FormFieldModel.getFormFieldByType,
      );
      if (itemFields.isEmpty) continue;
      items.add(
        RepeatingGroupItemModel(
          id: '${key ?? 'group'}_item_${_itemSequence++}',
          fields: itemFields,
          isExpanded: false,
        ),
      );
    }
  }

  RepeatingGroupConfigModel get config =>
      groupConfig ?? const RepeatingGroupConfigModel();

  int get minItems => config.minItems;

  int? get maxItems => config.maxItems;

  bool get canAddItem =>
      templateFieldsJson.isNotEmpty &&
      (maxItems == null || items.length < maxItems!);

  bool get canDeleteItem => config.allowDelete && items.length > minItems;

  /// Appends a new empty item, or returns `null` when the configured maximum
  /// is already reached.
  RepeatingGroupItemModel? addItem() {
    if (!canAddItem) return null;
    final item = RepeatingGroupItemModel(
      id: '${key ?? 'group'}_item_${_itemSequence++}',
      fields: _buildFields(),
    );
    items.add(item);
    return item;
  }

  bool removeItemAt(int index) {
    if (index < 0 || index >= items.length) return false;
    items.removeAt(index);
    return true;
  }

  /// Creates the items the definition requires to exist up front. Returns the
  /// number of items added.
  int ensureMinimumItems() {
    var added = 0;
    while (items.length < minItems && canAddItem) {
      if (addItem() == null) break;
      added++;
    }
    return added;
  }

  List<FormFieldModel> _buildFields() => templateFieldsJson
      .map(
        (fieldJson) => FormFieldModel.getFormFieldByType(
          _deepCloneJson(fieldJson) as Map<String, dynamic>,
        ),
      )
      .toList();

  static List<Map<String, dynamic>> _parseTemplateFieldsJson(dynamic data) {
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  /// Items must not share any part of the template, otherwise a nested option
  /// list or config map mutated by one item would be seen by all the others.
  static dynamic _deepCloneJson(dynamic value) {
    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key.toString(): _deepCloneJson(entry.value),
      };
    }
    if (value is List) return value.map(_deepCloneJson).toList();
    return value;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['groupConfig'] = config.toJson();
    json['fields'] = templateFieldsJson;
    return json;
  }
}
