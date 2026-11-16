part of '../../../omni_core.dart';

/// Base model for all form fields
class FormFieldModel {
  final String? key;
  final String? name;
  final FormFieldType? type;
  final String? title;
  final String? placeholder;
  final RequiredValidation? required;
  final Map<String, dynamic>? css;

  /// Condition under which the field is shown. `null` means always shown.
  final VisibilityRulesModel? visibilityRules;

  /// Makes the field required whenever it is visible, alongside
  /// `required.value`. A hidden field is never required, whichever is set.
  final bool? requiredWhenVisible;

  FormFieldModel({
    this.key,
    this.name,
    this.type,
    this.title,
    this.placeholder,
    this.required,
    this.css,
    this.visibilityRules,
    this.requiredWhenVisible,
  });

  FormFieldModel.fromJson(Map<String, dynamic>? json)
    : key = AppBaseModel.parseString(json?['key']),
      name = AppBaseModel.parseString(json?['name']),
      type = FormFieldType.fromString(AppBaseModel.parseString(json?['name'])),
      title = AppBaseModel.parseString(json?['title']),
      placeholder = AppBaseModel.parseString(json?['placeholder']),
      required = json?['required'] != null
          ? RequiredValidation.fromJson(
              AppBaseModel.parseMap(json?['required']),
            )
          : null,
      css = AppBaseModel.parseMap(json?['css']),
      visibilityRules = json?['visibilityRules'] != null
          ? VisibilityRulesModel.fromJson(
              AppBaseModel.parseMap(json?['visibilityRules']),
            )
          : null,
      requiredWhenVisible = AppBaseModel.parseBool(
        json?['requiredWhenVisible'],
      );

  /// Whether the field must hold a value while it is visible.
  bool get isRequiredWhenVisible =>
      required?.value == true || requiredWhenVisible == true;

  factory FormFieldModel.getFormFieldByType(Map<String, dynamic>? json) {
    if (json == null) return FormFieldModel();

    final type = FormFieldType.fromString(
      AppBaseModel.parseString(json['name']),
    );

    // Handle structure fields first
    if (type == FormFieldType.container) {
      return ContainerFormFieldModel.fromJson(json);
    }
    if (type == FormFieldType.repeatinggroup) {
      return RepeatingGroupFormFieldModel.fromJson(json);
    }

    switch (type) {
      case FormFieldType.input:
        return TextFormFieldModel.fromJson(json);
      case FormFieldType.numberinput:
        return NumberFormFieldModel.fromJson(json);
      case FormFieldType.dropdown:
        // The backend sends dynamic dropdowns as regular dropdowns; they are
        // distinguished by their `data.entityConfig`.
        if (DynamicDropdownFormFieldModel.isDynamicDropdownJson(json)) {
          return DynamicDropdownFormFieldModel.fromJson(json);
        }
        return DropdownFormFieldModel.fromJson(json);
      case FormFieldType.dynamicDropdown:
        return DynamicDropdownFormFieldModel.fromJson(json);
      case FormFieldType.multiselect:
        // The backend sends dynamic multi-selects as regular ones; they are
        // distinguished by their `data.entityConfig`.
        if (DynamicMultiSelectFormFieldModel.isDynamicMultiSelectJson(json)) {
          return DynamicMultiSelectFormFieldModel.fromJson(json);
        }
        return MultiSelectFormFieldModel.fromJson(json);
      case FormFieldType.dynamicMultiselect:
        return DynamicMultiSelectFormFieldModel.fromJson(json);
      case FormFieldType.checkbox:
        return CheckboxFormFieldModel.fromJson(json);
      case FormFieldType.datetime:
        return DateTimePickerFormFieldModel.fromJson(json);
      case FormFieldType.datepicker:
        return DatePickerFormFieldModel.fromJson(json);
      case FormFieldType.radiogroup:
        return RadioGroupFormFieldModel.fromJson(json);
      case FormFieldType.textarea:
        return TextAreaFormFieldModel.fromJson(json);
      case FormFieldType.toggle:
        return ToggleFormFieldModel.fromJson(json);
      case FormFieldType.signature:
        return SignatureFormFieldModel.fromJson(json);
      case FormFieldType.takephoto:
        return TakePhotoFormFieldModel.fromJson(json);
      case FormFieldType.multipleTakePhotos:
        return MultipleTakePhotosFormFieldModel.fromJson(json);
      case FormFieldType.uploader:
        return FileUploaderFormFieldModel.fromJson(json);
      case FormFieldType.derivedvalue:
        return DerivedValueFormFieldModel.fromJson(json);
      case FormFieldType.computedvalue:
        return ComputedValueFormFieldModel.fromJson(json);
      case FormFieldType.header:
        return HeaderFormFieldModel.fromJson(json);
      case FormFieldType.image:
        return ImageFormFieldModel.fromJson(json);
      case FormFieldType.label:
        return LabelFormFieldModel.fromJson(json);
      case FormFieldType.link:
        return LinkFormFieldModel.fromJson(json);
      case FormFieldType.progresscircle:
        return ProgressCircleFormFieldModel.fromJson(json);
      case FormFieldType.progressline:
        return ProgressLineFormFieldModel.fromJson(json);

      default:
        return FormFieldModel.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': type?.name,
    'title': title,
    'placeholder': placeholder,
    'required': required?.toJson(),
    'css': css,
    'type': type?.name,
    if (visibilityRules != null) 'visibilityRules': visibilityRules!.toJson(),
    if (requiredWhenVisible != null) 'requiredWhenVisible': requiredWhenVisible,
  };
}

class RequiredValidation {
  final bool? value;
  final String? validationMessage;

  RequiredValidation({this.value, this.validationMessage});

  factory RequiredValidation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RequiredValidation();

    try {
      return RequiredValidation(
        value: AppBaseModel.parseBool(json['value']),
        validationMessage: AppBaseModel.parseString(json['validationMessage']),
      );
    } catch (e, s) {
      PackageLogger.error(
        'Error parsing RequiredValidation: $e',
        stackTrace: s,
      );
      return RequiredValidation();
    }
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'validationMessage': validationMessage,
  };
}
