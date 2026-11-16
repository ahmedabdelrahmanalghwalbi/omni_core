part of '../../../../omni_core.dart';

class RadioGroupFieldWidget extends StatefulWidget {
  final RadioGroupFormFieldModel radiogroupFormFieldModel;
  final double spacing;
  final double innerSpacing;
  final TextStyle labelTextStyle;
  final TextStyle optionTextStyle;
  final double radioSize;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle fieldLabelTextStyle;
  final Color fieldBorderColor;
  final double fieldBorderWidth;
  final Color fieldFillColor;
  final double fieldHeight;
  final double fieldIconSize;
  final double fieldRadius;
  final TextStyle fieldTextStyle;
  final bool isReadOnly;
  final bool isEditMode;
  final Color primaryColor;
  final bool? showValidationMessage;
  final void Function(String?) onChanged;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const RadioGroupFieldWidget({
    super.key,
    required this.radiogroupFormFieldModel,
    required this.radioSize,
    required this.spacing,
    required this.innerSpacing,
    required this.labelTextStyle,
    required this.optionTextStyle,
    required this.activeColor,
    required this.inactiveColor,
    required this.fieldLabelTextStyle,
    required this.fieldBorderColor,
    required this.fieldBorderWidth,
    required this.fieldFillColor,
    required this.fieldHeight,
    required this.fieldIconSize,
    required this.fieldRadius,
    required this.fieldTextStyle,
    required this.primaryColor,
    this.isReadOnly = false,
    this.isEditMode = false,
    this.showValidationMessage,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.onChanged,
  });

  @override
  State<RadioGroupFieldWidget> createState() => _RadioGroupFieldWidgetState();
}

class _RadioGroupFieldWidgetState extends State<RadioGroupFieldWidget> {
  Map<String, dynamic>? selectedOption;
  String otherValue = '';

  @override
  void initState() {
    super.initState();
    final submittedValue = widget.radiogroupFormFieldModel.submittedValue;
    if (widget.isReadOnly && (submittedValue?.isNotEmpty ?? false)) {
      // Find selected option
      final radioGroupOptions = widget.radiogroupFormFieldModel.data;
      if (radioGroupOptions?.isNotEmpty ?? false) {
        for (final option in radioGroupOptions!) {
          if (option['value']?.toString() == submittedValue) {
            selectedOption = option;
            break;
          }
        }
      }
      // If not found, treat it as custom value
      if (selectedOption?.isEmpty ?? true) {
        selectedOption = {'label': submittedValue, 'value': submittedValue};
        otherValue = submittedValue!;
        // Add custom value to data [options]
        widget.radiogroupFormFieldModel.data?.add(selectedOption!);
      }
    } else {
      // Editable mode: seed the selection from the current value so a
      // pre-filled or draft-restored value shows as selected.
      _seedSelectionFromValue(widget.radiogroupFormFieldModel.value);
    }
  }

  void _seedSelectionFromValue(String? value) {
    if (value == null || value.isEmpty) return;
    final options = widget.radiogroupFormFieldModel.data;
    if (options != null) {
      for (final option in options) {
        if (option['value']?.toString() == value) {
          selectedOption = option;
          return;
        }
      }
    }
    // Not one of the predefined options → restore it as a custom "other" value.
    selectedOption = {'label': 'Other Option', 'value': 'other'};
    otherValue = value;
  }

  void _handleSelection(Map<String, dynamic> option) {
    setState(() {
      selectedOption = option;
      if (option['value'] != 'other') {
        widget.onChanged.call(AppBaseModel.parseString(option['value']));
      } else {
        // Wait for user to type custom value
        widget.onChanged.call(otherValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      ...widget.radiogroupFormFieldModel.data ?? [],
      if (!widget.isReadOnly) {'label': 'Other Option', 'value': 'other'},
    ];

    return Container(
      margin: EdgeInsets.only(bottom: widget.spacing),
      padding: EdgeInsets.symmetric(horizontal: widget.spacing),
      child: Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        spacing: widget.innerSpacing,
        children: [
          if (widget.radiogroupFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: widget.radiogroupFormFieldModel.title!,
              isRequired:
                  widget.radiogroupFormFieldModel.required?.value == true,
              style: widget.fieldLabelTextStyle,
            ),
          ...options.map((option) {
            final isSelected = selectedOption?['value'] == option['value'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: widget.innerSpacing,
              children: [
                GestureDetector(
                  onTap: widget.isReadOnly
                      ? null
                      : () => _handleSelection(option),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    spacing: widget.innerSpacing,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_on
                            : Icons.radio_button_off,
                        color: isSelected
                            ? widget.activeColor
                            : widget.inactiveColor,
                        size: widget.radioSize,
                      ),
                      Expanded(
                        child: Text(
                          AppBaseModel.parseString(option['label']) ?? '',
                          style: widget.optionTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!widget.isReadOnly &&
                    option['value'] == 'other' &&
                    selectedOption?['value'] == 'other')
                  Container(
                    margin: EdgeInsets.only(
                      left: widget.innerSpacing,
                      top: widget.innerSpacing,
                    ),
                    child: TextFieldWidget(
                      // Seed the custom input from [otherValue] so a restored
                      // (or in-progress) "Other" value is shown, not blank.
                      textFormFieldModel: TextFormFieldModel(value: otherValue),
                      fieldBorderColor: widget.fieldBorderColor,
                      fieldBorderWidth: widget.fieldBorderWidth,
                      fieldFillColor: widget.fieldFillColor,
                      fieldHeight: widget.fieldHeight,
                      fieldIconSize: widget.fieldIconSize,
                      fieldRadius: widget.fieldRadius,
                      fieldTextStyle: widget.fieldTextStyle,
                      fieldLabelTextStyle: widget.fieldLabelTextStyle,
                      spacing: widget.spacing,
                      innerSpacing: widget.innerSpacing,
                      isReadOnly: widget.isReadOnly,
                      primaryColor: widget.primaryColor,
                      onChanged: (value) {
                        otherValue = value;
                        widget.onChanged.call(value);
                      },
                    ),
                  ),
              ],
            );
          }),
          FieldValidationMessageWidget(
            requiredValidation: widget.radiogroupFormFieldModel.required,
            showValidationMessage: widget.showValidationMessage,
          ),
        ],
      ),
    );
  }
}
