part of '../../../../omni_core.dart';

class ProgressLineFieldWidget extends StatelessWidget {
  final ProgressLineFormFieldModel progressLineFormFieldModel;
  final double spacing;
  final double innerSpacing;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldHintStyle;
  final double progressLineFieldHeight;
  final double fieldRadius;
  final Color fieldFillColor;
  final Color primaryColor;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ProgressLineFieldWidget({
    super.key,
    required this.progressLineFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.fieldHintStyle,
    required this.fieldRadius,
    required this.progressLineFieldHeight,
    required this.fieldFillColor,
    required this.primaryColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = progressLineFormFieldModel.data ?? 0;
    final maxValue = progressLineFormFieldModel.maxValue ?? 100;
    final minValue = progressLineFormFieldModel.minValue ?? 0;
    final percentage = ((currentValue - minValue) / (maxValue - minValue))
        .clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (progressLineFormFieldModel.title?.isNotEmpty ?? false)
            if (progressLineFormFieldModel.title?.isNotEmpty ?? false)
              FieldTitleWithRequiredWidget(
                title: progressLineFormFieldModel.title!,
                isRequired: progressLineFormFieldModel.required?.value == true,
                style: fieldLabelTextStyle,
              ),

          Row(
            spacing: innerSpacing,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: progressLineFieldHeight,
                  backgroundColor: fieldFillColor,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  borderRadius: BorderRadius.circular(fieldRadius),
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: fieldLabelTextStyle,
              ),
            ],
          ),
          Text(
            '$currentValue/$maxValue',
            textAlign: TextAlign.center,
            style: fieldHintStyle,
          ),
        ],
      ),
    );
  }
}
