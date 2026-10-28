import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class GYMTrainerExtWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool isRating;
  const GYMTrainerExtWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.isRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: greyLight2.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 10),
              blurRadius: 20,
              color: black.withValues(alpha: 0.05),
            )
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Helper(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: primaryText1,
                      letterSpacing: -0.5,
                    ),
              ),
              if (isRating) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.star_rounded,
                  color: goldColor,
                  size: 20,
                ),
              ],
            ],
          ),
          sizedBoxHeight(height: 4),
          Text(
            subTitle.toUpperCase(),
            style: Helper(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  color: greyText3,
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}
