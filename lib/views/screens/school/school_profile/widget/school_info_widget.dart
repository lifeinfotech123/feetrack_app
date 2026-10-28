import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class SchoolInfoWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  const SchoolInfoWidget({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                color: blackText1,
              ),
        ),
        Text(
          subTitle,
          style: Helper(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: greyDart2,
              ),
        ),
      ],
    );
  }
}
