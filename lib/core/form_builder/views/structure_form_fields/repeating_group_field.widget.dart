part of '../../../../omni_core.dart';

/// Builds one field of a repeating-group item.
///
/// [itemScope] is the scope the field belongs to, so dependent dropdowns,
/// visibility rules and calculations resolve against the item the field is in
/// and never against another item or the top-level fields.
typedef RepeatingGroupItemFieldBuilder =
    Widget Function(
      FormFieldModel field,
      List<FormFieldModel> itemScope,
      void Function(String fieldKey, dynamic value) onFieldChanged,
    );

/// Renders a [RepeatingGroupFormFieldModel]: its items, the configured add and
/// delete actions, and the empty state.
///
/// Everything it shows comes from `groupConfig`; the widget knows nothing about
/// what a form actually repeats.
class RepeatingGroupFieldWidget extends StatelessWidget {
  final RepeatingGroupFormFieldModel groupFormFieldModel;
  final RepeatingGroupItemFieldBuilder itemFieldBuilder;
  final bool isReadOnly;

  /// Called when the technician adds an item; the host appends it to the model
  /// and rebuilds.
  final VoidCallback? onAddItem;

  /// Called when the technician deletes an item. The host confirms the deletion
  /// when the item already holds data.
  final void Function(int itemIndex)? onDeleteItem;

  /// Called when an item is expanded or collapsed.
  final void Function(int itemIndex, bool isExpanded)? onItemExpandedChanged;

  /// Called after a field of an item changed, so the host can prune hidden
  /// values, recalculate and persist the draft.
  final void Function(int itemIndex, String fieldKey, dynamic value)
  onItemFieldChanged;

  final String emptyStateText;
  final String addItemText;
  final String itemLabelText;
  final String deleteItemText;
  final String editItemText;
  final String maxItemsReachedText;
  final String minItemsRequiredText;
  final bool showValidationMessage;

  final Color primaryColor;
  final Locale locale;
  final double spacing;
  final double innerSpacing;
  final double fieldRadius;
  final Color fieldFillColor;
  final double fieldBorderSize;
  final Color fieldBorderColor;
  final double fieldIconSize;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final TextStyle fieldHintStyle;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const RepeatingGroupFieldWidget({
    super.key,
    required this.groupFormFieldModel,
    required this.itemFieldBuilder,
    required this.onItemFieldChanged,
    required this.primaryColor,
    required this.locale,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldFillColor,
    required this.fieldBorderSize,
    required this.fieldBorderColor,
    required this.fieldIconSize,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    required this.fieldHintStyle,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    this.onAddItem,
    this.onDeleteItem,
    this.onItemExpandedChanged,
    this.isReadOnly = false,
    this.showValidationMessage = false,
    this.emptyStateText = 'No items yet',
    this.addItemText = 'Add item',
    this.itemLabelText = 'Item',
    this.deleteItemText = 'Delete',
    this.editItemText = 'Edit',
    this.maxItemsReachedText = 'Maximum number of items reached',
    this.minItemsRequiredText = 'Please add the required items',
  });

  static const int _summaryMaxEntries = 4;

  RepeatingGroupConfigModel get _config => groupFormFieldModel.config;

  String get _groupTitle =>
      groupFormFieldModel.config.groupTitle?.trim().isNotEmpty == true
      ? groupFormFieldModel.config.groupTitle!
      : (groupFormFieldModel.title ?? '');

  String get _itemLabel => _config.itemLabel?.trim().isNotEmpty == true
      ? _config.itemLabel!
      : itemLabelText;

  String get _addItemLabel => _config.addItemLabel?.trim().isNotEmpty == true
      ? _config.addItemLabel!
      : addItemText;

  bool get _isBelowMinimum =>
      groupFormFieldModel.items.length < groupFormFieldModel.minItems;

  @override
  Widget build(BuildContext context) {
    final items = groupFormFieldModel.items;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      margin: EdgeInsets.only(bottom: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (_groupTitle.isNotEmpty)
            FieldTitleWithRequiredWidget(
              title: _groupTitle,
              isRequired: groupFormFieldModel.minItems > 0,
              style: fieldLabelTextStyle,
            ),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: spacing,
                horizontal: innerSpacing,
              ),
              decoration: BoxDecoration(
                color: fieldFillColor,
                borderRadius: BorderRadius.circular(fieldRadius),
                border: Border.all(
                  color: fieldBorderColor,
                  width: fieldBorderSize,
                ),
              ),
              alignment: AlignmentDirectional.center,
              child: Text(
                emptyStateText,
                textAlign: TextAlign.center,
                style: fieldHintStyle,
              ),
            )
          else
            for (final (index, item) in items.indexed)
              _RepeatingGroupItemCardWidget(
                key: item.cardKey,
                item: item,
                itemNumber: index + 1,
                itemLabel: _itemLabel,
                deleteItemText: deleteItemText,
                editItemText: editItemText,
                isReadOnly: isReadOnly,
                isCollapsible: _config.collapsibleItems,
                canDelete:
                    !isReadOnly &&
                    _config.allowDelete &&
                    items.length > groupFormFieldModel.minItems,
                // Reopening a submitted item is reading it, not editing it, so
                // it stays available whatever the definition allows.
                canEdit: isReadOnly || _config.allowEdit,
                showValidationMessage: showValidationMessage,
                locale: locale,
                primaryColor: primaryColor,
                spacing: spacing,
                innerSpacing: innerSpacing,
                fieldRadius: fieldRadius,
                fieldBorderColor: fieldBorderColor,
                fieldBorderSize: fieldBorderSize,
                fieldFillColor: fieldFillColor,
                fieldIconSize: fieldIconSize,
                fieldLabelTextStyle: fieldLabelTextStyle,
                fieldTextStyle: fieldTextStyle,
                fieldHintStyle: fieldHintStyle,
                itemFieldBuilder: itemFieldBuilder,
                onFieldChanged: (fieldKey, value) =>
                    onItemFieldChanged(index, fieldKey, value),
                onDelete: onDeleteItem == null
                    ? null
                    : () => onDeleteItem!(index),
                onExpandedChanged: onItemExpandedChanged == null
                    ? null
                    : (isExpanded) =>
                          onItemExpandedChanged!(index, isExpanded),
              ),
          if (!isReadOnly)
            SizedBox(
              width: double.infinity,
              child: groupFormFieldModel.canAddItem
                  ? OutlinedButton.icon(
                      onPressed: onAddItem,
                      icon: Icon(Icons.add, size: fieldIconSize * 0.8),
                      label: Text(_addItemLabel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(
                          color: primaryColor,
                          width: fieldBorderSize,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(fieldRadius),
                        ),
                        padding: EdgeInsets.symmetric(vertical: innerSpacing),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: innerSpacing),
                      child: Text(
                        maxItemsReachedText,
                        style: fieldHintStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          if (showValidationMessage && _isBelowMinimum)
            Text(
              minItemsRequiredText,
              style: fieldHintStyle.copyWith(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

/// One item of a repeating group: expanded for editing, or collapsed to a
/// compact summary of what it already holds.
class _RepeatingGroupItemCardWidget extends StatelessWidget {
  final RepeatingGroupItemModel item;
  final int itemNumber;
  final String itemLabel;
  final String deleteItemText;
  final String editItemText;
  final bool isReadOnly;
  final bool isCollapsible;
  final bool canDelete;
  final bool canEdit;
  final bool showValidationMessage;
  final Locale locale;
  final Color primaryColor;
  final double spacing;
  final double innerSpacing;
  final double fieldRadius;
  final Color fieldBorderColor;
  final double fieldBorderSize;
  final Color fieldFillColor;
  final double fieldIconSize;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldTextStyle;
  final TextStyle fieldHintStyle;
  final RepeatingGroupItemFieldBuilder itemFieldBuilder;
  final void Function(String fieldKey, dynamic value) onFieldChanged;
  final VoidCallback? onDelete;
  final void Function(bool isExpanded)? onExpandedChanged;

  const _RepeatingGroupItemCardWidget({
    super.key,
    required this.item,
    required this.itemNumber,
    required this.itemLabel,
    required this.deleteItemText,
    required this.editItemText,
    required this.isReadOnly,
    required this.isCollapsible,
    required this.canDelete,
    required this.canEdit,
    required this.showValidationMessage,
    required this.locale,
    required this.primaryColor,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldRadius,
    required this.fieldBorderColor,
    required this.fieldBorderSize,
    required this.fieldFillColor,
    required this.fieldIconSize,
    required this.fieldLabelTextStyle,
    required this.fieldTextStyle,
    required this.fieldHintStyle,
    required this.itemFieldBuilder,
    required this.onFieldChanged,
    this.onDelete,
    this.onExpandedChanged,
  });

  bool get _isExpanded => item.isExpanded || !isCollapsible;

  /// An expanded item can always be collapsed again; reopening a collapsed one
  /// is what the definition may withhold.
  bool get _showsToggleAction =>
      isCollapsible &&
      onExpandedChanged != null &&
      (_isExpanded || canEdit);

  @override
  Widget build(BuildContext context) {
    final itemScope = FormFieldScopeUtils.flatten(item.fields);
    final visibleFields = FormVisibilityUtils.visibleFields(
      item.fields,
      itemScope,
      useSubmittedValues: isReadOnly,
    );

    final summary = _isExpanded ? '' : _summaryOf(visibleFields);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: innerSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(fieldRadius),
        border: Border.all(color: fieldBorderColor, width: fieldBorderSize),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: isCollapsible,
            label: '$itemLabel $itemNumber',
            child: InkWell(
              onTap: isCollapsible && onExpandedChanged != null
                  ? () => onExpandedChanged!(!item.isExpanded)
                  : null,
              borderRadius: BorderRadius.circular(fieldRadius),
              child: Padding(
                padding: EdgeInsets.all(innerSpacing),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$itemLabel $itemNumber',
                            style: fieldLabelTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (summary.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: innerSpacing / 2),
                              child: Text(
                                summary,
                                style: fieldHintStyle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: innerSpacing),
                    if (canDelete && onDelete != null)
                      RepeatingGroupItemActionWidget(
                        semanticsLabel: deleteItemText,
                        backgroundColor: RepeatingGroupItemActionWidget
                            .destructiveBackgroundColor,
                        icon: RepeatingGroupItemActionWidget.iconOf(
                          PackageAssetsConstants.formRepeatingGroupDeleteItem,
                        ),
                        onPressed: onDelete,
                      ),
                    if (canDelete && onDelete != null && _showsToggleAction)
                      SizedBox(width: innerSpacing / 2),
                    if (_showsToggleAction)
                      RepeatingGroupItemActionWidget(
                        semanticsLabel: editItemText,
                        backgroundColor: fieldFillColor,
                        icon: _isExpanded
                            ? Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: RepeatingGroupItemActionWidget
                                    .defaultIconSize,
                                color: primaryColor,
                              )
                            : RepeatingGroupItemActionWidget.iconOf(
                                PackageAssetsConstants
                                    .formRepeatingGroupEditItem,
                              ),
                        onPressed: () => onExpandedChanged!(!item.isExpanded),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.only(top: innerSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final field in visibleFields)
                    itemFieldBuilder(field, itemScope, onFieldChanged),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// A compact line describing what the item already holds, built from the
  /// values themselves so it works for any form.
  String _summaryOf(List<FormFieldModel> visibleFields) {
    final entries = <String>[];
    for (final field in visibleFields) {
      if (entries.length >= RepeatingGroupFieldWidget._summaryMaxEntries) break;
      if (field is! InputFormFieldModel) continue;
      final text = _displayTextOf(
        isReadOnly ? field.submittedValue : field.value,
      );
      if (text.isEmpty) continue;
      entries.add(text);
    }
    return entries.join(' • ');
  }

  String _displayTextOf(Object? value) {
    if (value == null) return '';
    if (value is Map) {
      return AppBaseModel.parseString(
            value['displayValue'] ?? value['label'] ?? value['value'],
          )?.trim() ??
          '';
    }
    if (value is DateTime) {
      return DateTimeUtils.formatReadableDate(
        dateTime: value,
        locale: locale.languageCode,
      );
    }
    if (value is File) return '';
    if (value is Iterable) {
      return value
          .map(_displayTextOf)
          .where((text) => text.isNotEmpty)
          .join(', ');
    }
    if (value is num) return FormCalculationUtils.formatValue(value);
    return value.toString().trim();
  }
}
