import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class StudentProfileWidget extends StatelessWidget {
  const StudentProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CustomImage(
          path: Assets.imagesReview1,
          height: 48,
          width: 48,
          fit: BoxFit.cover,
          radius: 999,
        ),
        sizedBoxWidth(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vinod Johnson",
                overflow: TextOverflow.ellipsis,
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      color: blackText1,
                    ),
              ),
              sizedBoxHeight(height: 2),
              Text(
                "Grade 8 • Section B",
                style: Helper(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: greyDart2,
                    ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_outlined,
          color: greyDart2,
        )
      ],
    );
  }
}
