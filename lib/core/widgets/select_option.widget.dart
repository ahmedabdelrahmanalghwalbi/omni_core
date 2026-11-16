part of '../../omni_core.dart';

class SelectOptionWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final VoidCallback onTap;
  final String searchHintText;
  final Map<String, dynamic>? selectedValue;
  final List<Map<String, dynamic>>? items;
  final void Function(Map<String, dynamic>)? onChanged;
  final double? opacity;
  final bool? showPrefixLoadingWidget;
  final double? height;
  final double? contentPadding;
  final TextStyle? hintStyle;
  final bool? isRequired;
  final AutovalidateMode? autoValidateMode;
  final BorderSide? errorBorderSide;
  final TextStyle? errorStyle;
  final String? errorText;
  final void Function()? onRemoveClicked;
  final String? Function(String?)? validator;
  final bool? showRedAsterisk;
  final Color? inputFillColor;
  final bool isEnabled;

  const SelectOptionWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.onTap,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.searchHintText,
    this.showRedAsterisk,
    this.showPrefixLoadingWidget,
    this.opacity,
    this.height,
    this.contentPadding,
    this.hintStyle,
    this.isRequired,
    this.autoValidateMode,
    this.errorBorderSide,
    this.errorStyle,
    this.errorText,
    this.onRemoveClicked,
    this.validator,
    this.inputFillColor,
    this.isEnabled = true,
  });

  static const TextStyle _dropdownTextStyle = TextStyle(
    // color: Color(0xff9E9E9E),
    color: Colors.black87,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle _dropdownSelectedTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
  );

  Widget? getFieldSuffixIcon() {
    if (showPrefixLoadingWidget == true) {
      return Transform.scale(
        scale: 0.3,
        child: const CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(0xff9E9E9E)),
          strokeWidth: 6,
        ),
      );
    }
    if (isEnabled == false) {
      return const Icon(Icons.lock, color: Color(0xff9E9E9E), size: 20.0);
    }

    if (isRequired == true) {
      return const Icon(
        Icons.keyboard_arrow_down_outlined,
        color: Color(0xff9E9E9E),
        size: 20.0,
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8.0,
    children: [
      Text.rich(
        TextSpan(
          text: title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
          children: showRedAsterisk == true
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]
              : [],
        ),
      ),
      Opacity(
        opacity: opacity ?? 1.0,
        child: IgnorePointer(
          ignoring: !isEnabled,
          child: SizedBox(
            height: height,
            child: CustomDropdown.search(
              searchHintText: searchHintText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: contentPadding ?? 8.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
              fillColor: inputFillColor ?? const Color(0xffEEEEEE),
              borderSide: const BorderSide(color: Color(0xffE0E0E0)),
              nameKey: 'name',
              nameMapKey: 'ar',
              selectedValue: selectedValue,
              hintText: hintText,
              items: items,
              onChanged: (val) {
                onChanged?.call(val);
              },
              hintStyle: hintStyle ?? _dropdownTextStyle,
              labelStyle: _dropdownTextStyle,
              listItemStyle: _dropdownTextStyle,
              selectedStyle: _dropdownSelectedTextStyle,
              fieldSuffixIcon: getFieldSuffixIcon(),
              autovalidateMode: autoValidateMode,
              errorBorderSide: errorBorderSide,
              errorStyle: errorStyle,
              errorText: errorText,
              onRemoveClicked: onRemoveClicked,
              validator: validator,
            ),
          ),
        ),
      ),
    ],
  );
}
