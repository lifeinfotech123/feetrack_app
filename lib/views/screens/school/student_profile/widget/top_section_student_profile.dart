import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class TopSectionStudentProfile extends StatelessWidget {
  const TopSectionStudentProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: greyLight2,
            child: const CustomImage(
              path: Assets.imagesReview1,
              height: 88,
              width: 88,
              fit: BoxFit.cover,
              radius: 999,
            ),
          ),
        ),
        sizedBoxHeight(height: 20),
        Text(
          "Vinod Johnson",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 24,
                color: blackText3,
              ),
        ),
        sizedBoxHeight(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          decoration: BoxDecoration(
            color: grey.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            "Grade 8 - Division A",
            style: Helper(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: greyDart2,
                ),
          ),
        )
      ],
    );
  }
}
