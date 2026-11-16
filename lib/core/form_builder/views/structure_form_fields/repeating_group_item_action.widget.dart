part of '../../../../omni_core.dart';

/// One action of a repeating-group item: a square, tinted, rounded button.
///
/// Shared by every action a group item offers, so they stay one shape and one
/// size wherever they appear.
class RepeatingGroupItemActionWidget extends StatelessWidget {
  final Widget icon;
  final Color backgroundColor;
  final double size;
  final double borderRadius;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  const RepeatingGroupItemActionWidget({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.semanticsLabel,
    required this.onPressed,
    this.size = defaultSize,
    this.borderRadius = defaultBorderRadius,
  });

  /// Sized for a comfortable tap target while staying visually secondary to
  /// the item's own content.
  static const double defaultSize = 40.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 18.0;

  /// Tint behind a destructive action.
  static const Color destructiveBackgroundColor = Color(0xFFFFECEC);

  /// Builds the icon of an action from an asset shipped with this package.
  static Widget iconOf(String assetPath, {double size = defaultIconSize}) =>
      SvgPicture.asset(
        assetPath,
        package: 'omni_core',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticsLabel,
    child: Tooltip(
      message: semanticsLabel,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: icon),
          ),
        ),
      ),
    ),
  );
}
