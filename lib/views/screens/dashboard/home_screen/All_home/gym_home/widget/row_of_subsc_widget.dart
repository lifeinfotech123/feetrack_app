import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class RowOfSubscWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  const RowOfSubscWidget({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.clip,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: greyText2,
                ),
          ),
        ),
        Expanded(
          child: Text(
            subTitle,
            textAlign: TextAlign.end,
            overflow: TextOverflow.clip,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: blackText1,
                ),
          ),
        ),
      ],
    );
  }
}
