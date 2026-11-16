part of '../../omni_core.dart';

class CustomElevatedButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String title;
  final ButtonStyle? buttonStyle;
  final Widget? titleWidget;
  final double? width;
  final double? height;
  final TextStyle? titleStyle;
  final double? radius;
  final Color? backgroundColor;
  final bool? isFuture;
  final double? elevation;
  final bool? showOnlyCircularIndicatorWhileLoading;
  final List<Color>? gradientBackgroundColors;
  final List<Color>? gradientStrokeColors;
  final bool? isDisabled;
  final Color? disabledColor;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.backgroundColor,
    this.buttonStyle,
    this.titleWidget,
    this.titleStyle,
    this.radius,
    this.width,
    this.height,
    this.elevation,
    this.isFuture = true,
    this.showOnlyCircularIndicatorWhileLoading,
    this.gradientBackgroundColors,
    this.gradientStrokeColors,
    this.isDisabled,
    this.disabledColor,
  });

  @override
  CustomElevatedButtonState createState() => CustomElevatedButtonState();
}

class CustomElevatedButtonState extends State<CustomElevatedButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _controller;
  final int duration = 200;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePressed() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _controller.forward();
    try {
      await widget.onPressed();
    } catch (err, t) {
      PackageLogger.error(
        '📦 Error in animated loading button future',
        error: err,
        stackTrace: t,
      );
    }
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // ✅ just use colors directly
  List<Color> get _gradientColors => widget.gradientBackgroundColors!;

  List<Color> get _strokeColors =>
      widget.gradientStrokeColors ?? widget.gradientBackgroundColors!;

  double get _currentRadius =>
      (_isLoading && widget.showOnlyCircularIndicatorWhileLoading != true)
      ? 26.0
      : (widget.radius ?? 28.0);

  Widget get _buttonChild => widget.isFuture == true && _isLoading
      ? const Center(
          child: SizedBox(
            width: 22.0,
            height: 22.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        )
      : widget.titleWidget ??
            Text(
              widget.title,
              style:
                  widget.titleStyle ??
                  const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => AnimatedContainer(
      duration: Duration(milliseconds: duration),
      width:
          (_isLoading && widget.showOnlyCircularIndicatorWhileLoading != true)
          ? 75.0
          : (widget.width ?? 200.0),
      height: widget.height ?? 50.0,

      // ✅ if gradient passed, use it, else keep normal
      child:
          widget.gradientBackgroundColors != null &&
              widget.gradientBackgroundColors!.length >= 2
          ? _buildGradientButton()
          : _buildNormalButton(),
    ),
  );

  // ✅ Normal button (existing behavior)
  Widget _buildNormalButton() => ElevatedButton(
    style:
        widget.buttonStyle ??
        ElevatedButton.styleFrom(
          backgroundColor: widget.isDisabled == true
              ? (widget.disabledColor ?? Colors.grey)
              : widget.backgroundColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: widget.elevation ?? 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_currentRadius),
          ),
        ),
    onPressed: widget.isDisabled == true
        ? null
        : widget.isFuture == true
        ? _isLoading
              ? () {}
              : _handlePressed
        : widget.onPressed,
    child: _buttonChild,
  );

  // ✅ Gradient button
  Widget _buildGradientButton() => GestureDetector(
    onTap: widget.isDisabled == true
        ? null
        : widget.isFuture == true
        ? _isLoading
              ? () {}
              : _handlePressed
        : widget.onPressed,
    child: Container(
      decoration: BoxDecoration(
        color: widget.isDisabled == true
            ? (widget.disabledColor ?? Colors.grey)
            : null,
        gradient: widget.isDisabled == true
            ? null
            : LinearGradient(
                colors: _gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(_currentRadius),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: widget.isDisabled == true
                ? [
                    widget.disabledColor ?? Colors.grey,
                    widget.disabledColor ?? Colors.grey,
                  ]
                : _strokeColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          width: 1.5,
        ),
      ),
      child: Center(child: _buttonChild),
    ),
  );
}
