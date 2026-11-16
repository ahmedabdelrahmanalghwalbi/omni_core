part of '../../../../omni_core.dart';

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({
    required WidgetBuilder builder,
    required this.barrierBackgroundColor,
    required this.duration,
    super.settings,
    super.fullscreenDialog,
  }) : _builder = builder;

  final WidgetBuilder _builder;
  final Color barrierBackgroundColor;
  final int duration;
  @override
  bool get opaque => false;
  @override
  bool get barrierDismissible => true;
  @override
  Duration get transitionDuration => Duration(milliseconds: duration);
  @override
  bool get maintainState => true;
  @override
  Color get barrierColor => barrierBackgroundColor;
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => _builder(context);

  @override
  String get barrierLabel => 'Animated Search Popup is Opened';
}
