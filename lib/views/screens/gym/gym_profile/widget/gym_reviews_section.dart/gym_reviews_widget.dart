import 'package:easy_stars/easy_stars.dart';
import 'package:flutter/material.dart';
import 'package:vlr/data/models/reviews_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/date_formatters_and_converters.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class GYMReviewsWidget extends StatelessWidget {
  final ReviewsModel reviewsModel;
  const GYMReviewsWidget({
    super.key,
    required this.reviewsModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //! user reviews iamge
              CustomImage(
                path: Assets.imagesReview1,
                height: 56,
                width: 56,
                isProfile: true,
                radius: 999,
              ),
              Text(
                reviewsModel.createdAt ?? "",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: greyText2),
              ),
            ],
          ),
          sizedBoxHeight(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reviewsModel.customerName ?? "",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: blackText1,
                        letterSpacing: 0.5),
                  ),
                  // Text(
                  //   gymReviewsModel.userPackageName,
                  //   style: Helper(context).textTheme.bodyMedium?.copyWith(
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w600,
                  //       color: greyText3,
                  //       letterSpacing: 0.5),
                  // ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EasyStarsRating(
                    initialRating: reviewsModel.rating?.toDouble() ?? 0.0,
                    allowHalfRating: true,
                    filledColor: greenDark,
                    starSize: 16,
                  ),
                ],
              ),
            ],
          ),
          sizedBoxHeight(height: 12),
          Text(
            reviewsModel.comment ?? "",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: greyText2,
                ),
          )
        ],
      ),
    );
  }
}
