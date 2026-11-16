part of '../omni_core.dart';

enum AnimationTypes { none, fade, slide }

abstract class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  static void subscribeRouteObserver({required RouteAware routeAware}) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    try {
      final route = ModalRoute.of(ctx);
      if (route is PageRoute) {
        routeObserver.subscribe(routeAware, route);
      }
    } catch (ex, st) {
      PackageLogger.error(
        'Error subscribing route observer',
        error: ex,
        stackTrace: st,
      );
    }
  }

  static void unsubscribeRouteObserver({required RouteAware routeAware}) {
    try {
      routeObserver.unsubscribe(routeAware);
    } catch (ex, st) {
      PackageLogger.error(
        'Error unsubscribing route observer',
        error: ex,
        stackTrace: st,
      );
    }
  }

  static Future<dynamic> navigateTo(
    Widget Function() creator, {
    bool replace = false,
    bool replaceAll = false,
    AnimationTypes animationType = AnimationTypes.none,
  }) {
    final navigator = navigatorKey.currentState!;
    final route = _createRoute(creator, animationType);

    if (replaceAll) {
      return navigator.pushAndRemoveUntil(route, (route) => false);
    } else if (replace) {
      return navigator.pushReplacement(route);
    } else {
      return navigator.push(route);
    }
  }

  static void goBack<T>({T? result}) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  static void goBackUntil({required String routeName}) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  static PageRoute _createRoute(
    Widget Function() creator,
    AnimationTypes type,
  ) {
    final context = navigatorKey.currentContext!;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoPageRoute(builder: (_) => creator());
    }

    switch (type) {
      case AnimationTypes.fade:
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => creator(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      case AnimationTypes.slide:
        return PageRouteBuilder(
          pageBuilder: (_, _, _) => creator(),
          transitionsBuilder: (_, animation, _, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => creator());
    }
  }

  static Future<bool> showConfirmMessageWithLogo({
    required String title,
    String? message,
    String? imageSvgAsset,
    Widget? icon,
    String confirmText = 'Confirm',
    String denyText = 'Cancel',
    Color confirmButtonColor = Colors.blue,
    Color denyButtonColor = Colors.white,
    double width = 320.0,
    double borderRadius = 12.0,
    bool? showOnlyConfirmButton,
  }) async {
    final result = await showDialog<bool>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          insetPadding: EdgeInsets.zero,
          child: Container(
            constraints: BoxConstraints(maxWidth: width),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🖼️ Image or Icon
                if (imageSvgAsset != null)
                  SvgPicture.asset(imageSvgAsset, width: 120, height: 80)
                else if (icon != null)
                  SizedBox(width: 100, height: 80, child: icon),

                const SizedBox(height: 16.0),

                /// 📝 Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (message != null) ...[
                  const SizedBox(height: 12.0),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 20.0),

                /// ✅❌ Ok & No Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomActionButtonWidget(
                      text: confirmText,
                      backgroundColor: confirmButtonColor,
                      isPrimary: false,
                      width: 135.0,
                      height: 40,
                      borderRadius: 5.0,
                      onPressed: () => Navigator.pop(dialogContext, true),
                      gredientColors: [Colors.red, confirmButtonColor],
                      isGredient: true,
                    ),
                    if (showOnlyConfirmButton != true) ...[
                      const SizedBox(width: 10.0),
                      CustomActionButtonWidget(
                        isPrimary: true,
                        text: denyText,
                        backgroundColor: denyButtonColor,
                        width: 135.0,
                        height: 40,
                        borderRadius: 5.0,
                        onPressed: () => Navigator.pop(dialogContext, false),
                        isGredient: true,
                        gredientColors: [denyButtonColor, denyButtonColor],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return result ?? false;
  }

  static Future<bool> showConfirmDialogWithOptionalTextField({
    required BuildContext context,
    required String title,
    required String confirmText,
    required String cancelText,
    required Future<void> Function()? onConfirm,
    Color confirmButtonColor = const Color(0xffE53935),
    double borderRadius = 8.0,
    String? message,
    bool? withTextField,
    TextEditingController? textFieldController,
    String? textFieldHintText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
          constraints: const BoxConstraints(maxWidth: 400.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 18.0,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (message?.isNotEmpty ?? false)
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (withTextField == true && textFieldController != null)
                CustomTextFieldColumnWidget(
                  controller: textFieldController,
                  label: null,
                  hintText: textFieldHintText ?? '',
                  validator: null,
                  fillColor: const Color(0xffEEEEEE),
                ),
              Column(
                spacing: 8.0,
                children: [
                  // Confirm button
                  CustomElevatedButton(
                    title: confirmText,
                    backgroundColor: confirmButtonColor,
                    radius: borderRadius,
                    onPressed: () async {
                      if (onConfirm != null) {
                        await onConfirm();
                      }
                    },
                    isFuture: true,
                    titleStyle: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    elevation: 0,
                    showOnlyCircularIndicatorWhileLoading: true,
                    width: double.infinity,
                  ),

                  // Cancel button
                  CustomElevatedButton(
                    title: cancelText,
                    radius: borderRadius,
                    backgroundColor: null,
                    onPressed: () async {
                      goBack<bool>(result: false);
                    },
                    isFuture: false,
                    titleStyle: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                    elevation: 0,
                    width: double.infinity,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }
}
