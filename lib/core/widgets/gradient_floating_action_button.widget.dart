part of '../../omni_core.dart';

class GradientFloatingActionButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final List<Color> gradientColors;
  final double? size;
  final double strokeWidth;
  final double elevation;

  const GradientFloatingActionButtonWidget({
    super.key,
    required this.onPressed,
    required this.child,
    required this.gradientColors,
    this.size,
    this.strokeWidth = 1.5,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: FloatingActionButton(
      shape: const CircleBorder(),
      backgroundColor: Colors.transparent,
      elevation: elevation,
      onPressed: onPressed,
      child: child,
    ),
  );
}
