part of '../../omni_core.dart';

abstract class LayoutUtils {
  // standard breakpoints
  static const double _mobileMaxWidth = 650;
  static const double _tabletMaxWidth = 1200;

  /// check if the device is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileMaxWidth &&
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// check if the device is tabled
  static bool isTablet(BuildContext context) =>
      (MediaQuery.of(context).size.width >= _mobileMaxWidth &&
          MediaQuery.of(context).size.width < _tabletMaxWidth) ||
      (MediaQuery.of(context).orientation == Orientation.landscape &&
          MediaQuery.of(context).size.width < _tabletMaxWidth);

  /// check if the device is desctop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  /// return device screen width
  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// return device screen height
  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// convert pixel to sheet percentage
  static double convertPixelToSheetPercentage({
    required double pixelValue,
    required double sheetParentWidgetHeight,
    double maxPercentage = 0.85,
  }) => (pixelValue / sheetParentWidgetHeight).clamp(0.0, maxPercentage);

  /// bind the widget depond on screen size
  static Widget bindWidget(
    BuildContext context, {
    Widget Function()? mobileWidget,
    Widget Function()? tabletWidget,
    Widget Function()? descktopWidget,
  }) //: assert(context != null)
  {
    //return descktopWidget;
    if (MediaQuery.of(context).size.width > 1200) {
      final c =
          descktopWidget ??
          tabletWidget ??
          mobileWidget ??
          () => const SizedBox();
      return c();
    }
    if (MediaQuery.of(context).size.width > 650 ||
        MediaQuery.of(context).orientation == Orientation.landscape) {
      final c =
          tabletWidget ??
          descktopWidget ??
          mobileWidget ??
          () => const SizedBox();
      return c();
    }

    final c =
        mobileWidget ??
        tabletWidget ??
        descktopWidget ??
        () => const SizedBox();
    return c();
  }
}
