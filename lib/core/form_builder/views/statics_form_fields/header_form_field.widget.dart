part of '../../../../omni_core.dart';

class HeaderFieldWidget extends StatelessWidget {
  final HeaderFormFieldModel headerFormFieldModel;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle fieldLabelTextStyle;
  final Color primaryColor;

  const HeaderFieldWidget({
    super.key,
    required this.headerFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.primaryColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if ((headerFormFieldModel.data?.isEmpty ?? true) &&
        (headerFormFieldModel.title?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: FieldTitleWithRequiredWidget(
        title: headerFormFieldModel.data ?? headerFormFieldModel.title ?? '',
        isRequired: headerFormFieldModel.required?.value == true,
        style: fieldLabelTextStyle.copyWith(
          fontSize: 17.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
