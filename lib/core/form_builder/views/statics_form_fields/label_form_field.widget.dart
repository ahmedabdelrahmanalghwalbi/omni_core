part of '../../../../omni_core.dart';

class LabelFieldWidget extends StatelessWidget {
  final LabelFormFieldModel lableFormFieldModel;
  final double spacing;
  final double innerSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle fieldLabelTextStyle;
  final Color primaryColor;
  final VoidCallback? onLabelFieldTab;

  const LabelFieldWidget({
    super.key,
    required this.lableFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.primaryColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.onLabelFieldTab,
  });

  @override
  Widget build(BuildContext context) {
    if ((lableFormFieldModel.data?.isEmpty ?? true) &&
        (lableFormFieldModel.title?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: GestureDetector(
        onTap: onLabelFieldTab,
        child: Text(
          lableFormFieldModel.data ?? lableFormFieldModel.title ?? '',
          style: fieldLabelTextStyle.copyWith(
            color: onLabelFieldTab != null ? Colors.blue : null,
            decoration: onLabelFieldTab != null
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
