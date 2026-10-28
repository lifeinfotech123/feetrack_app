import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class SchoolProfileRowHighlightWidget extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  const SchoolProfileRowHighlightWidget({
    super.key,
    required this.iconWidget,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 6,
          color: greyLight6,
        ),
        sizedBoxWidth(width: 12),
        iconWidget,
        sizedBoxWidth(width: 4),
        Text(
          title,
          style: Helper(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: greyDart2,
              ),
        ),
      ],
    );
  }
}
