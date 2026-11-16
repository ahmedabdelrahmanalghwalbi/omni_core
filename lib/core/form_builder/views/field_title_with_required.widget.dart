part of '../../../omni_core.dart';

class FieldTitleWithRequiredWidget extends StatelessWidget {
  final String title;
  final bool isRequired;
  final TextStyle? style;

  const FieldTitleWithRequiredWidget({
    super.key,
    required this.title,
    this.isRequired = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: title, style: style),
        if (isRequired)
          TextSpan(
            text: ' *',
            style: (style ?? const TextStyle()).copyWith(color: Colors.red),
          ),
      ],
    ),
    softWrap: true,
    overflow: TextOverflow.visible,
  );
}
