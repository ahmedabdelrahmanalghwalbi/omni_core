part of '../../omni_core.dart';

class MultiSelectOptionWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final VoidCallback onTap;
  final String nameKey;
  final int maxSelectedItems;
  final String searchHintText;
  final Color primaryColor;
  final List<Map<String, dynamic>>? selectedValue;
  final List<Map<String, dynamic>>? items;
  final void Function(List<Map<String, dynamic>>)? onChanged;
  final double? opacity;
  final bool? showPrefixLoadingWidget;
  final String? subNameKey;
  final String primaryIdKey;
  final Color? selectedItemChipBackgroundColor;
  final void Function(List<Map<String, dynamic>>)? onComplete;
  final CustomMultiDropdownController? controller;
  final VoidCallback? onMaxItemsSelected;
  final VoidCallback? onCancel;

  const MultiSelectOptionWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.onTap,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.searchHintText,
    required this.primaryColor,
    this.showPrefixLoadingWidget,
    this.opacity,
    this.maxSelectedItems = 5,
    this.nameKey = 'name',
    required this.subNameKey,
    this.primaryIdKey = 'id',
    this.selectedItemChipBackgroundColor,
    this.onComplete,
    this.controller,
    this.onMaxItemsSelected,
    this.onCancel,
  });

  static const TextStyle _dropdownTextStyle = TextStyle(
    color: Color(0xff9E9E9E),
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
    return const Icon(
      Icons.keyboard_arrow_down_outlined,
      color: Color(0xff9E9E9E),
      size: 20.0,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8.0,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      Opacity(
        opacity: opacity ?? 1.0,
        child: CustomMultiDropdown.search(
          searchHintText: searchHintText,
          controller: controller,
          selectColor: primaryColor,
          selectedItemChipBackgroundColor: selectedItemChipBackgroundColor,
          maxSelectedItems: maxSelectedItems,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          borderRadius: BorderRadius.circular(8.0),
          fillColor: const Color(0xffEEEEEE),
          borderSide: const BorderSide(color: Color(0xffE0E0E0)),
          nameKey: nameKey,
          primaryIdKey: primaryIdKey,
          nameMapKey: 'ar',
          selectedValues: selectedValue,
          hintText: hintText,
          items: items,
          onChanged: (val) {
            onChanged?.call(val);
          },
          onComplete: onComplete,
          onMaxItemsSelected: onMaxItemsSelected,
          hintStyle: _dropdownTextStyle,
          labelStyle: _dropdownTextStyle,
          listItemStyle: _dropdownTextStyle,
          selectedStyle: _dropdownSelectedTextStyle,
          subNameKey: subNameKey,
          fieldSuffixIcon: getFieldSuffixIcon(),
        ),
      ),
    ],
  );
}
