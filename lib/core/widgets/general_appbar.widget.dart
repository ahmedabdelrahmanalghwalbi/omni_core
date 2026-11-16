part of '../../omni_core.dart';

class GeneralAppbarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool? showBackArrowButton;
  final List<Widget>? actions;
  final Color primaryColor;
  final Color titleColor;
  final Color iconColor;
  const GeneralAppbarWidget({
    super.key,
    required this.title,
    required this.primaryColor,
    this.showBackArrowButton,
    this.actions,
    this.titleColor = Colors.white,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
    ),
    backgroundColor: primaryColor,
    centerTitle: true,
    leading: showBackArrowButton == true ? null : const SizedBox.shrink(),
    iconTheme: IconThemeData(color: iconColor),
    actions: actions,
  );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
