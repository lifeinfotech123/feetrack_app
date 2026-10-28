import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextStyle? style;
  final TextAlign textAlign;
  const CustomText(
    this.text, {
    super.key,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style: style,
    );
  }
}
