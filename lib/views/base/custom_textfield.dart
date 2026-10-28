import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@Deprecated("Do Not Use this Widget, instead use TextField from Flutter")
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.onChange,
    this.color,
    this.keyBoardType,
    this.hindText,
    required this.onTap,
    this.borderRadius,
    this.hintColor,
    required this.validate,
    this.maxLengh,
    required this.controller,
    this.suffixIcon,
    this.inputFrmtrs,
    this.obscure,
    this.prefixWidget,
  }) : super(key: key);
  final TextEditingController controller;
  final Function onChange;
  final Color? color;
  final List<TextInputFormatter>? inputFrmtrs;
  final Widget? suffixIcon;
  final Widget? prefixWidget;
  final Color? hintColor;
  final bool? obscure;
  final TextInputType? keyBoardType;
  final String? hindText;
  final Function() onTap;
  final double? borderRadius;
  final String? Function(String?)? validate;
  final int? maxLengh;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextFormField(
        obscureText: obscure ?? false,
        controller: controller,
        onChanged: (value) {
          onChange(value);
        },
        inputFormatters: inputFrmtrs ?? [],
        textAlign: TextAlign.left,
        expands: false,
        keyboardType: keyBoardType ?? TextInputType.text,
        onTap: () {
          onTap();
        },
        validator: (value) {
          return validate!(value);
        },
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: obscure != null ? 1 : maxLengh,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          suffixIcon: Padding(
            padding: const EdgeInsets.only(
              right: 5,
            ),
            child: suffixIcon,
          ),
          prefix: Padding(
            padding: const EdgeInsets.only(
              right: 5,
            ),
            child: prefixWidget,
          ),
          prefixIconConstraints: const BoxConstraints(
            maxHeight: 25,
            maxWidth: 25,
          ),
          suffixIconConstraints: const BoxConstraints(
            maxHeight: 25,
            maxWidth: 25,
          ),
          hintText: hindText,
          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).hintColor,
              ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          fillColor: Colors.grey.shade100,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
