import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/input_decoration.dart';
import 'package:vlr/services/theme.dart';

class AppPasswordTextBox extends StatefulWidget {
  final TextEditingController passwordController;
  final String? heading;
  final bool obscureShow;
  const AppPasswordTextBox(
      {super.key,
      required this.passwordController,
      this.heading,
      this.obscureShow = true});

  @override
  State<AppPasswordTextBox> createState() => _AppPasswordTextBoxState();
}

class _AppPasswordTextBoxState extends State<AppPasswordTextBox> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.heading != null) ...[
          Text(
            widget.heading!,
            style: Helper(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
        ],
        TextFormField(
          controller: widget.passwordController,
          obscureText: widget.obscureShow ? obscureText : false,
          decoration: CustomDecoration.inputDecoration(
            icon: const Icon(
              Icons.lock_outline,
              size: 18,
            ),
            suffix: widget.obscureShow
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_sharp
                          : Icons.visibility_off_sharp,
                      color: grey,
                      size: 20,
                    ),
                  )
                : const SizedBox(),
            bgColor: grey.withValues(alpha: 0.1),
            hintStyle: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: greyText,
                ),
            borderColor: grey.withValues(alpha: 0.5),
            hint: "Enter your password",
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            return null;
          },
        ),
      ],
    );
  }
}
