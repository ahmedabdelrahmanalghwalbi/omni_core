part of '../../omni_core.dart';

abstract class ModalSheetUtils<T> {
  static void _showBlurDialog({required BuildContext ctx}) {
    showGeneralDialog(
      context: ctx,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38.withAlpha(40),
      pageBuilder: (_, __, ___) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Container(
          color: Colors.white.withAlpha(25),
          alignment: Alignment.bottomCenter,
          child: Container(),
        ),
      ),
    );
  }

  static Future<T?> showCustomModalSheet<T>({
    required Widget modalContent,
    required double height,
    EdgeInsets? contentPadding,
    String? title,
    bool showSheetHolder = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
  }) async {
    final _ctx = AppRouter.navigatorKey.currentContext;
    if (_ctx == null) return null;
    _showBlurDialog(ctx: _ctx);
    final T? result = await showModalBottomSheet(
      context: _ctx,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      barrierColor: barrierColor ?? Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      ),
      useSafeArea: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) => Container(
        padding: contentPadding,
        height: height + MediaQuery.of(context).viewInsets.bottom,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.0,
          children: [
            // Modal Sheet Holder
            if (showSheetHolder)
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xffDFE2EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            // Modal Sheet title
            if (title?.isNotEmpty ?? false)
              Text(
                title!,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            // Modal Sheet Content
            modalContent,
          ],
        ),
      ),
    );

    /// dismiss blur
    AppRouter.goBack<void>();
    return result;
  }
}
