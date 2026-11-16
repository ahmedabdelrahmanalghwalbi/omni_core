part of '../../omni_core.dart';

class CustomDividerWidget extends StatelessWidget {
  final Color? dividerColor;
  final double? dividerThickness;
  const CustomDividerWidget({
    super.key,
    this.dividerColor,
    this.dividerThickness,
  });

  @override
  Widget build(BuildContext context) => Divider(
    color: dividerColor ?? const Color(0xffE8EDF1),
    thickness: dividerThickness ?? 1.0,
  );
}
