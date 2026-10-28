import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class RowOfPersonalDetailsWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  const RowOfPersonalDetailsWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              color: primaryText1.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999)),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: primaryText1,
          ),
        ),
        sizedBoxWidth(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: greyText2,
                    ),
              ),
              sizedBoxHeight(height: 4),
              Text(
                subTitle,
                overflow: TextOverflow.clip,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryText1,
                    ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
