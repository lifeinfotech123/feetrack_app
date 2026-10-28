import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/basic_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class ReviewRatingRow extends StatelessWidget {
  const ReviewRatingRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasicController>(builder: (basicController) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: greenDark,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: white,
                  size: 18,
                ),
                sizedBoxWidth(width: 4.5),
                Text(
                  basicController.averageRating.toString(),
                  style: Helper(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: white,
                      ),
                )
              ],
            ),
          ),
          sizedBoxWidth(width: 8),
          Text(
            "(${basicController.totalReviews} reviews)",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: white,
                ),
          ),
          sizedBoxWidth(width: 8),
        ],
      );
    });
  }
}
