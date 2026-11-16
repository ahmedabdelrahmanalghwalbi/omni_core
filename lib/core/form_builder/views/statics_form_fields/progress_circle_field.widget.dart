part of '../../../../omni_core.dart';

class ProgressCircleFieldWidget extends StatelessWidget {
  final ProgressCircleFormFieldModel progressCircleFormFieldModel;
  final double spacing;
  final double innerSpacing;
  final TextStyle fieldLabelTextStyle;
  final TextStyle fieldHintStyle;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double progressCircleFieldRadiusSize;
  final Color fieldFillColor;
  final Color primaryColor;

  const ProgressCircleFieldWidget({
    super.key,
    required this.progressCircleFormFieldModel,
    required this.spacing,
    required this.innerSpacing,
    required this.fieldLabelTextStyle,
    required this.progressCircleFieldRadiusSize,
    required this.fieldFillColor,
    required this.fieldHintStyle,
    required this.primaryColor,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = progressCircleFormFieldModel.data ?? 0;
    final maxValue = progressCircleFormFieldModel.maxValue ?? 100;
    final percentage = maxValue > 0 ? (currentValue / maxValue * 100) : 0;

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: innerSpacing,
        children: [
          if (progressCircleFormFieldModel.title?.isNotEmpty ?? false)
            FieldTitleWithRequiredWidget(
              title: progressCircleFormFieldModel.title!,
              isRequired: progressCircleFormFieldModel.required?.value == true,
              style: fieldLabelTextStyle,
            ),
          SizedBox(
            height: progressCircleFieldRadiusSize,
            width: progressCircleFieldRadiusSize,
            child: syncfusion_charts.SfCircularChart(
              series: <syncfusion_charts.CircularSeries>[
                syncfusion_charts.DoughnutSeries<Map<String, dynamic>, String>(
                  dataSource: [
                    {
                      'value': percentage,
                      'color': currentValue > 0 ? primaryColor : fieldFillColor,
                    },
                    {'value': 100 - percentage, 'color': fieldFillColor},
                  ],
                  xValueMapper: (data, _) => '',
                  yValueMapper: (data, _) =>
                      AppBaseModel.parseNum(data['value']),
                  pointColorMapper: (data, _) => data['color'] as Color?,
                  radius: '100%',
                  innerRadius: '85%',
                  cornerStyle: syncfusion_charts.CornerStyle.bothCurve,
                ),
              ],
              annotations: [
                syncfusion_charts.CircularChartAnnotation(
                  widget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${percentage.round()}%',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text('$currentValue/$maxValue', style: fieldHintStyle),
                    ],
                  ),
                ),
              ],
              margin: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
