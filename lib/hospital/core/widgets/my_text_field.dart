import 'package:flutter/material.dart';

import '../constants/colors.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';

// ignore: must_be_immutable
class MyTextField extends StatefulWidget {
  final bool isSecure;
  bool isPassword;
  final bool isEmail;
  final bool isNumber;
  final bool isMultiline;
  final TextEditingController controller;
  final String hint;
  final int? maxLength;
  final int? maxLines;
  final String? Function(String?) validation;
  final IconData? icon;
  final void Function(String)? onChanged;

  MyTextField(
      {this.isPassword = false,
      this.isEmail = false,
      this.isNumber = false,
      this.isMultiline = false,
      this.isSecure = false,
      required this.controller,
      this.hint = "",
      this.maxLength,
      this.maxLines = 1,
      required this.validation,
      this.icon,
      this.onChanged});

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: TextFormField(
        style: const TextStyle(fontSize: 14),
        cursorColor: primaryColor,
        maxLines: widget.maxLines,
        validator: widget.validation,
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        controller: widget.controller,
        obscureText: widget.isPassword,
        keyboardType: widget.isEmail
            ? TextInputType.emailAddress
            : (widget.isNumber
                ? TextInputType.number
                : (widget.isMultiline
                    ? TextInputType.multiline
                    : TextInputType.text)),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          labelText: widget.hint,
          labelStyle: const TextStyle(fontSize: 13),
          suffixIcon: widget.isSecure
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.isPassword = !widget.isPassword;
                    });
                  },
                  child: new Icon(
                    widget.isPassword ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                    size: 20,
                  ),
                )
              : null,
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: primaryColor,
                  size: 20,
                )
              : null,
          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
          hintText: widget.hint,
          hintStyle: TextStyle(color: hintColor, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: errorColor, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: errorColor, width: 1),
          ),
        ),
      ),
    );
  }
}
