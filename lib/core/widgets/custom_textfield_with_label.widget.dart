part of '../../omni_core.dart';

class CustomTextFieldColumnWidget extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final TextStyle? labelStyle;
  final bool? isPassword;
  final Color? fillColor;

  const CustomTextFieldColumnWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    required this.hintText,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 8.0,
    this.labelStyle,
    this.isPassword,
    this.fillColor,
  });

  @override
  State<CustomTextFieldColumnWidget> createState() =>
      _CustomTextFieldColumnWidgetState();
}

class _CustomTextFieldColumnWidgetState
    extends State<CustomTextFieldColumnWidget> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: widget.mainAxisAlignment,
    crossAxisAlignment: widget.crossAxisAlignment,
    spacing: widget.spacing,
    children: [
      if (widget.label?.isNotEmpty ?? false)
        Text(
          widget.label!,
          style:
              widget.labelStyle ??
              const TextStyle(
                color: Color(0xff000000),
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
        ),
      TextFormField(
        controller: widget.controller,
        obscureText: (widget.isPassword == true) ? _isObscured : false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: widget.hintText,
          filled: true,
          fillColor: widget.fillColor,
          suffixIcon: (widget.isPassword == true)
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xffBDBDBD),
                    size: 16.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
        validator: widget.validator,
      ),
    ],
  );
}
