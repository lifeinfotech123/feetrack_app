import 'package:flutter/material.dart';
import 'package:vlr/services/extensions.dart';

class CustomValidator<T> extends StatelessWidget {
  final Widget Function(FormFieldState<T> field) child;
  final String? Function(dynamic value) validator;
  const CustomValidator(
      {super.key, required this.child, required this.validator});

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: validator,
      builder: (FormFieldState<T> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child(field),
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Text(
                    field.errorText.getIfValid,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 11,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
