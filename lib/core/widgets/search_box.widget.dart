part of '../../omni_core.dart';

class SearchBoxWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final double radius;
  final TextStyle textStyle;
  final TextStyle hintTextStyle;
  final Color borderColor;
  final double height;
  final double borderSize;
  final bool isEnabled;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;
  final Color? backgroundColor;
  final FocusNode? focusNode;
  final bool? isLoading;
  final bool? showSearchField;
  final String? hintText;
  final TextEditingController? controller;
  const SearchBoxWidget({
    super.key,
    required this.onChanged,
    required this.textStyle,
    required this.borderColor,
    required this.height,
    required this.hintTextStyle,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
    this.radius = 12.0,
    this.borderSize = 1.0,
    this.backgroundColor,
    this.isEnabled = true,
    this.controller,
    this.focusNode,
    this.isLoading,
    this.showSearchField,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: borderColor, width: borderSize),
    );
    final InputDecoration primaryTextFieldDecoration = InputDecoration(
      labelStyle: textStyle,
      filled: true,
      fillColor: backgroundColor ?? const Color(0xffEEEEEE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      isDense: false,
      hintText: hintText ?? 'Search for Vehicles',
      hintStyle: hintTextStyle,
      prefixIcon: const Icon(
        Icons.search,
        size: 16.0,
        color: Color(0xff757575),
      ),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder,
      disabledBorder: fieldBorder,
      prefixIconConstraints: const BoxConstraints(minWidth: 30.0),
    );
    if (isLoading == true) {
      return _SearchBoxShimmerWidget(
        radius: radius,
        color: backgroundColor ?? const Color(0xffEEEEEE),
        height: height,
        shimmerBaseColor: shimmerBaseColor,
        shimmerHighlightColor: shimmerHighlightColor,
      );
    }
    if (showSearchField == false) return const SizedBox.shrink();
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: primaryTextFieldDecoration,
        style: textStyle,
        enabled: isEnabled,
      ),
    );
  }
}

class _SearchBoxShimmerWidget extends StatelessWidget {
  final double radius;
  final Color color;
  final double height;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  const _SearchBoxShimmerWidget({
    this.radius = 12.0,
    required this.color,
    required this.height,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: shimmerBaseColor,
    highlightColor: shimmerHighlightColor,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        spacing: 8.0,
        children: [
          Icon(Icons.search, size: 16.0, color: Colors.grey.shade400),
          Expanded(child: Container(height: 16.0, color: color)),
        ],
      ),
    ),
  );
}
