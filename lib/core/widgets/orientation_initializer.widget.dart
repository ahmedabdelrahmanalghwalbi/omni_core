part of '../../omni_core.dart';

class OrientationInitializerWidget extends StatefulWidget {
  final Widget child;
  final double? tabletBreakpoint;

  const OrientationInitializerWidget({
    super.key,
    required this.child,
    this.tabletBreakpoint,
  });

  @override
  State<OrientationInitializerWidget> createState() =>
      _OrientationInitializerWidgetState();
}

class _OrientationInitializerWidgetState
    extends State<OrientationInitializerWidget> {
  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= (widget.tabletBreakpoint ?? 700.0);
  }

  Future<void> _applyOrientation(BuildContext context) async {
    if (_isTablet(context)) {
      // Tablet → allow landscape + portrait
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Mobile → portrait only
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyOrientation(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
