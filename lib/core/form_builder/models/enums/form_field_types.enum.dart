part of '../../../../omni_core.dart';

enum FormFieldType {
  // inputs
  checkbox,
  datepicker,
  datetime,
  dropdown,
  dynamicDropdown,
  multiselect,
  dynamicMultiselect,
  input,
  numberinput,
  radiogroup,
  textarea,
  toggle,
  uploader,
  takephoto,
  multipleTakePhotos,
  signature,
  // calculated (read-only, resolved by the form engine)
  derivedvalue,
  computedvalue,
  // statics
  header,
  image,
  label,
  link,
  progresscircle,
  progressline,
  // structure
  container,
  repeatinggroup;

  static FormFieldType? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase().trim()) {
      case 'checkbox':
        return FormFieldType.checkbox;
      case 'datepicker':
        return FormFieldType.datepicker;
      case 'datetime':
      case 'date_time':
      case 'date-time':
      case 'date time':
        return FormFieldType.datetime;
      case 'dropdown':
        return FormFieldType.dropdown;
      case 'dynamicdropdown':
      case 'dynamic_dropdown':
      case 'dynamic-dropdown':
      case 'dynamic dropdown':
        return FormFieldType.dynamicDropdown;
      case 'multiselect':
      case 'multi_select':
      case 'multi-select':
      case 'multi select':
        return FormFieldType.multiselect;
      case 'dynamicmultiselect':
      case 'dynamic_multi_select':
      case 'dynamic-multi-select':
      case 'dynamic multi select':
        return FormFieldType.dynamicMultiselect;
      case 'input':
        return FormFieldType.input;
      case 'numberinput':
        return FormFieldType.numberinput;
      case 'radio_group':
      case 'radio group':
      case 'radio-group':
      case 'radiogroup':
        return FormFieldType.radiogroup;
      case 'text area':
      case 'text_area':
        return FormFieldType.textarea;
      case 'toggle':
        return FormFieldType.toggle;
      case 'uploader':
        return FormFieldType.uploader;
      case 'camera':
        return FormFieldType.takephoto;
      case 'header':
        return FormFieldType.header;
      case 'image':
        return FormFieldType.image;
      case 'label':
        return FormFieldType.label;
      case 'link':
        return FormFieldType.link;
      case 'progress_circle':
      case 'progress circle':
      case 'progresscircle':
        return FormFieldType.progresscircle;
      case 'progress_line':
      case 'progress line':
      case 'progressline':
        return FormFieldType.progressline;
      case 'signature':
        return FormFieldType.signature;
      case 'container':
        return FormFieldType.container;
      case 'repeatinggroup':
      case 'repeating_group':
      case 'repeating-group':
      case 'repeating group':
        return FormFieldType.repeatinggroup;
      case 'derivedvalue':
      case 'derived_value':
      case 'derived-value':
      case 'derived value':
        return FormFieldType.derivedvalue;
      case 'computedvalue':
      case 'computed_value':
      case 'computed-value':
      case 'computed value':
        return FormFieldType.computedvalue;
      default:
        PackageLogger.warning('Unknown FormFieldType: $value');
        return null;
    }
  }
}
