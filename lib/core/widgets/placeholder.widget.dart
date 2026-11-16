part of '../../omni_core.dart';

class PlaceholderWidget extends StatelessWidget {
  final String title;
  final IconData? icon;
  final double iconSize;
  final VoidCallback? onRetry;
  final double sectionBorderRadius;
  final String retryButtonText;
  final Color primaryColor;

  const PlaceholderWidget({
    super.key,
    required this.title,
    required this.retryButtonText,
    required this.primaryColor,
    this.icon,
    this.onRetry,
    this.sectionBorderRadius = 12.0,
    this.iconSize = 40.0,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      spacing: 24.0,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.0,
          children: [
            SvgPicture.asset(
              PackageAssetsConstants.noData,
              package: 'omni_core',
              width: 180.0,
              height: 80.0,
            ),
            AutoSizeText(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        if (onRetry != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomActionButtonWidget(
                isPrimary: true,
                text: retryButtonText,
                backgroundColor: primaryColor,
                // width: 150.0,
                borderRadius: sectionBorderRadius,
                onPressed: onRetry!,
                isGredient: true,
                gredientColors: [primaryColor, primaryColor],
              ),
            ],
          ),
      ],
    ),
  );
}
