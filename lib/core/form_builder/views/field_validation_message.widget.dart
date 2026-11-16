part of '../../../omni_core.dart';

class FieldValidationMessageWidget extends StatelessWidget {
  final RequiredValidation? requiredValidation;
  final bool? showValidationMessage;

  const FieldValidationMessageWidget({
    super.key,
    required this.requiredValidation,
    required this.showValidationMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (showValidationMessage == true) {
      if ((requiredValidation?.value == true) &&
          (requiredValidation?.validationMessage?.isNotEmpty ?? false)) {
        return Text(
          requiredValidation!.validationMessage!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}
